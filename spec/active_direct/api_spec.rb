require File.dirname(__FILE__) + '/../spec_helper'


describe "ActiveDirect::Api middleware" do
  before(:all) do
    get '/direct_api'
    @resp = last_response.body
  end
  
  it "should have valid response" do
    @resp.should include("=")
  end
  
  it "should have valid Ext.Direct remoting api configuration" do
    api_cfg = ActiveSupport::JSON.decode(@resp.split("=").last.delete(";"))
    api_cfg.should be_a_kind_of(Hash)
    api_cfg['type'].should eql("remoting")
    api_cfg['url'].should eql('/direct_router')
    ['Video', 'Category'].each do |model|
      api_cfg['actions'].should have_key(model)
    end

  end

end