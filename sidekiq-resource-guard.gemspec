require_relative 'lib/sidekiq_resource_guard/version'

Gem::Specification.new do |spec|
  spec.name          = "sidekiq-resource-guard"
  spec.version       = SidekiqResourceGuard::VERSION
  spec.authors       = ["Leandro Gomez"]
  spec.email         = ["leandrogoe@gmail.com"]

  spec.summary       = %q{A simple way to protect your resources from Sidekiq scaling}
  spec.homepage      = "https://github.com/leandrogoe/sidekiq-resource-guard"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.7.0")


  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/leandrogoe/sidekiq-resource-guard.git"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test/|spec/|features/|docker|Docker)}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'sidekiq', '>= 5.0.0', '< 7.0.0'
  spec.add_runtime_dependency 'mongo', '>= 2.0.0', '< 3.0.0'
end
