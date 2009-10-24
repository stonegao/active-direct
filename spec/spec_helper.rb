require "rubygems"
require 'activerecord'
require 'activesupport'
require "spec"
require "rack/test"
require 'rack'
require File.dirname(__FILE__) + '/../lib/active_direct'

plugin_spec_dir = File.dirname(__FILE__)
RAILS_ENV = 'test'
ActiveRecord::Base.logger = Logger.new(plugin_spec_dir + "/debug.log")

unless defined?(Rails)
	Rails = OpenStruct.new
	Rails.logger = ActiveRecord::Base.logger
end

test_db_file = File.join(plugin_spec_dir, 'db', 'test.sqlite3')
File.unlink(test_db_file) if File.exist?(test_db_file)
ActiveRecord::Base.establish_connection(
  "adapter" => "sqlite3", "database" => test_db_file
)
load(plugin_spec_dir + '/db/schema.rb')
require plugin_spec_dir + '/fixtures/models.rb'

Spec::Runner.configure do |config|
  config.include Rack::Test::Methods

  def app
    Rack::Builder.new do
      use ActiveDirect::Router, "/direct_router"
      use ActiveDirect::Api, "/direct_api", "/direct_router"
      map '/' do
        run Proc.new {|env| [200, {"Content-Type" => "text/html"}, "ActiveDirect test"] }
      end
    end.to_app
  end


	def do_post(params)
		post '/direct_router',{}, {'RAW_POST_DATA' => params.to_json }
	end

end


