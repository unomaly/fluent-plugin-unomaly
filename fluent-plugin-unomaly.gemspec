Gem::Specification.new do |spec|
    spec.name        = 'fluent-plugin-unomaly'
    spec.version     = '0.1.2'
  
    spec.summary     = "Fluentd output plugin for Unomaly"
    spec.description = "Fluentd output plugin for Unomaly"
    spec.authors     = ['Unomaly']
    spec.email       = 'support@unomaly.com'
    spec.files       = []
    spec.homepage    = 'https://github.com/unomaly/fluent-plugin-unomaly'
    spec.license     = 'MIT'
  
    spec.files         = `git ls-files -z`.split("\x0").reject do |f|
      f.match(%r{^(test|spec|features)/})
    end
    spec.require_paths = ["lib"]
  
    spec.required_ruby_version = '>= 2.0.0'
  
    spec.add_runtime_dependency "fluentd", "~> 0.12"
    spec.add_runtime_dependency "http", "< 3"
  
    spec.add_development_dependency "bundler", "~> 1.7"
    spec.add_development_dependency "rake", "~> 10.0"
    spec.add_development_dependency "webmock", "~> 2.1"
    spec.add_development_dependency "test-unit"
  end