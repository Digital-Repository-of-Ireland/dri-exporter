require 'simplecov'
SimpleCov.start do
  add_filter 'spec/'
  add_filter 'lib/dri/exporter/version.rb'
end

require "bundler/setup"
require "dri/exporter"

RSPEC_ROOT = File.dirname __FILE__

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

def fixture_path(fixture)
   File.join(RSPEC_ROOT, 'fixtures', fixture)
end
