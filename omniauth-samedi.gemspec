# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'omniauth-samedi/version'

Gem::Specification.new do |spec|
  spec.name          = 'omniauth-samedi'
  spec.version       = Omniauth::Samedi::VERSION
  spec.authors       = ['Damir Zekić']
  spec.email         = ['damir.zekic@toptal.com']

  spec.summary       = 'Samedi Booking API authentication strategy for OmniAuth'
  spec.description   = 'Samedi Booking API authentication strategy for OmniAuth implemented upon OmniAuth OAuth2 strategy.'
  spec.homepage      = 'https://github.com/samedi/omniauth-samedi'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = 'https://wiki.samedi.de/display/doc/Booking+API'
    spec.metadata['source_code_uri'] = spec.homepage
    spec.metadata['changelog_uri'] = 'https://github.com/samedi/omniauth-samedi/releases'
  else
    raise 'RubyGems 2.0 or newer is required to publish metadata'
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").select { |f| f.match(%r{^(lib/|LICENSE|README|omniauth-samedi\.gemspec)}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'omniauth', '~> 1.0'
  spec.add_dependency 'omniauth-oauth2', '~> 1.0'

  spec.add_development_dependency 'addressable', '~> 2.5'
  spec.add_development_dependency 'bundler', '~> 1.16'
  spec.add_development_dependency 'codecov'
  spec.add_development_dependency 'faraday'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'rack-test', '~> 1.0'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'simplecov'
  spec.add_development_dependency 'webmock', '~> 3.4'
end
