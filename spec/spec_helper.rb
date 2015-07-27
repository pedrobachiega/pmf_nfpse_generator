require 'pmf_nfpse_generator'

require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.tty = true
  config.formatter = :documentation
end
