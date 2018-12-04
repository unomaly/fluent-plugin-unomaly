FROM ruby:latest
RUN mkdir /unomaly
COPY ./ unomaly
WORKDIR /unomaly
RUN bundle install
RUN bundle exec rake test
RUN gem build fluent-plugin-unomaly.gemspec