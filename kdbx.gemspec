require_relative "lib/kdbx/version"

Gem::Specification.new do |spec|
  spec.name     = "kdbx"
  spec.author   = "rumtid"
  spec.version  = Kdbx::VERSION
  spec.summary  = "A kdbx library to access kdbx file format"
  spec.homepage = "https://github.com/rumtid/kdbx.rb"
  spec.license  = "MIT"

  spec.files = Dir["README.md", "LICENSE.txt", "lib/**/*.rb"]

  spec.add_runtime_dependency "rexml", "~> 3.1"
  spec.add_runtime_dependency "salsa20", "= 0.1.3"
  spec.add_development_dependency "rspec", "~> 3.5"
  spec.add_development_dependency "pry", "~> 0.10"
end
