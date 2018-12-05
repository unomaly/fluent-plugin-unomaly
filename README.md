# fluent-plugin-unomaly

[![Build Status](https://travis-ci.org/unomaly/fluent-plugin-unomaly.svg?branch=master)](https://travis-ci.org/unomaly/fluent-plugin-unomaly)

This plugin sends Fluents records to the [Unomaly](https://www.unomaly.com) ingestion API (min version Unomaly 2.27).

## Getting started

- Install plugin `gem install fluent-plugin-unomaly`
- Add to `fluent.conf`

Minimal configuration:

```
<match tag>
  @type unomaly
  host https://my-unomaly.instance
  flush_interval 1s
  source_key host
  message_key message
</match>
```

# Important configuration options

| Option                   | Description                                                                                                                                                                  | Default    |
| ------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| host                     | Unomaly instance address.                                                                                                                                                    | No default |
| message_key              | The field that contains the full/raw log message that Unomaly should look at for anomaly detection                                                                           | "message"  |
| source_key               | The field that will be used to associate this event with a system in Unomaly (should be a field that uniquely identifies the system the message comes from, like a hostname) | "host"     |
| accept_self_signed_certs | Accept self signed SSL certificate                                                                                                                                           | "false"    |

## Contributing

Bug reports and pull requests are welcome. This project is intended to
be a safe, welcoming space for collaboration.
