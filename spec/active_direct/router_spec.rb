require File.dirname(__FILE__) + '/../spec_helper'

describe "ActiveDirect::Router" do
  before(:each) do
    Category.delete_all
    Video.delete_all
  end

  it "should handle http raw post" do
    Category.count.should == 0
    params = {:action => 'Category', :method => 'create', :data => [{:name => 'category name'}], :type => 'rpc', :tid => 1 }
    do_post(params)
    Category.count.should == 1
  end
  # TODO
  it "should handle form post"
  # TODO 
  it "should handle form post with file upload"
end