# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'kafka_connection/version'

Gem::Specification.new do |spec|
  spec.name          = "kafka_connection"
  spec.version       = KafkaConnection::VERSION
  spec.authors       = ["Robin Daugherty"]
  spec.email         = ["robin@robindaugherty.net"]

  spec.summary       = %q{Manages one or more connections to Kafka using ruby-kafka.}
  spec.homepage      = "https://github.com/omniboard/kafka_connection-ruby"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://gem.fury.io'
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.13"
  spec.add_development_dependency "rake", "~> 12"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "rspec_junit_formatter", "~> 0.2.3"
  spec.add_development_dependency "codacy-coverage", "~> 1.1"
  spec.add_development_dependency "pry-byebug", "~> 3.4"

  spec.add_runtime_dependency "ruby-kafka", "~> 0.3"
  spec.add_runtime_dependency "connection_pool", "~> 2.2"
end
