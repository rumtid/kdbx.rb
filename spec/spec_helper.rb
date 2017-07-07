require "bundler/setup"
require "kdbx"
require "pry"

RSpec.configure do |config|
  config.example_status_persistence_file_path = ".rspec_status"
  config.expect_with(:rspec) { |c| c.syntax = :expect }
end
