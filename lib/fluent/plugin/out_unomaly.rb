require 'fluent/output'
require 'date'
require 'time'
require 'uri'
require 'net/http'
require 'net/https'

module Fluent
  class UnomalyOutput < BufferedOutput
    Fluent::Plugin.register_output('unomaly', self)

    # config_param defines a parameter. You can refer a parameter via @path instance variable

    # Event batch size to send to Unomaly. Increasing the batch size can increase throughput by reducing HTTP overhead
    config_param :batch_size,  :integer, :default => 50

    # Unomaly host to send the logs to
    config_param :host,  :string

    # Key that will be used by Unomaly as the log message
    config_param :message_key,  :string, :default => "message"

    # Key that will be used by Unomaly as the log message
    config_param :date_key,  :string, :default => nil

    # Key that will be used by Unomaly as the system key
    config_param :source_key,  :string, :default => "host"

    # Unomaly api path to push events
    config_param :api_path,  :string, :default => "/v1/batch"

    # Display debug logs
    config_param :debug,  :bool, :default => false

    config_param :accept_self_signed_certs, :bool, :default => false

    # This method is called before starting.
    # 'conf' is a Hash that includes configuration parameters.
    # If the configuration is invalid, raise Fluent::ConfigError.
    def configure(conf)
      super
      conf["buffer_chunk_limit"] ||= "500k"
      conf["flush_interval"] ||= "1s"
    end

    # This method is called when starting.
    # Open sockets or files here.
    def start
      super
    end

    # This method is called when shutting down.
    # Shutdown the thread and close sockets or files here.
    def shutdown
      super
    end

    # This method is called when an event reaches to Fluentd.
    # Convert the event to a raw string.
    def format(tag, time, record)
      [tag, time, record].to_msgpack
    end

    # This method is called every flush interval. Write the buffer chunk
    # to files or databases here.
    # 'chunk' is a buffer chunk that includes multiple formatted
    # events. You can use 'data = chunk.read' to get all events and
    # 'chunk.open {|io| ... }' to get IO objects.
    #
    # NOTE! This method is called by internal thread, not Fluentd's main thread. So IO wait doesn't affect other plugins.
    def write(chunk)
      documents = []
      chunk.msgpack_each do |(tag, time, record)|
        unomaly_event = {
            message: record[@message_key],
            source: record[@source_key],
            timestamp: Time.at(time).utc.to_datetime.rfc3339
        }
        metadata = record.to_hash

        metadata.delete(@source_key)
        metadata.delete(@message_key)
        metadata["tag"]=tag

        unomaly_event["metadata"]=metadata

        if @debug
          log.info "Event #{unomaly_event.to_json}"
        end
        documents.push(unomaly_event)
      end
      send_batch(documents)
    end

    def send_batch(events)
      url = @host + @api_path
      body = events.to_json
      ssl = url.start_with?('https')
      uri = URI.parse(url)
      header = {'Content-Type' => 'application/json'}

      http = Net::HTTP.new(uri.host, uri.port)
      if ssl
        http.use_ssl = true
        if @accept_self_signed_certs
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
        end
      end

      request = Net::HTTP::Post.new(uri.request_uri, header)
      request.body = body

      resp = http.request(request)
      if !resp.kind_of? Net::HTTPSuccess
        log.error "Error sending batch #{resp.to_s}"
      end
    end


    def flatten(data, prefix)
      ret = {}
      if data.is_a? Hash
        data.each { |key, value|
          if prefix.to_s.empty?
            ret.merge! flatten(value, "#{key.to_s}")
          else
            ret.merge! flatten(value, "#{prefix}.#{key.to_s}")
          end
        }
      elsif data.is_a? Array
        data.each_with_index {|val,index | ret.merge! flatten(val, "#{prefix}.#{index}")}
      else
        return {prefix => data.to_s}
      end

      ret
    end
  end
end