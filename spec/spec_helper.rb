require 'zuora'
require 'artifice'
require 'digest/md5'
require 'factory_girl'
require 'debugger'

Zuora.configure(:log => false)

Dir["#{File.dirname(__FILE__)}/../spec/support/**/*.rb"].sort.each { |ext| require ext }
Dir["#{File.dirname(__FILE__)}/../spec/factories/*.rb"].sort.each { |ext| require ext }

RSpec.configure do |c|
  I18n.enforce_available_locales = true
  c.include FactoryGirl::Syntax::Methods
  c.include Namespace
end

def generate_key
  Digest::MD5.hexdigest("#{Time.now}-#{rand}")
end
