require 'rubygems'
require 'rspec'
require 'mocha'
require 'trinidad'
require 'trinidad_scheduler_extension'

RSpec.configure do |config|
  config.mock_framework = :mocha
end

MOCK_WEB_APP_DIR = File.join(File.dirname(__FILE__), 'web_app_mock')
