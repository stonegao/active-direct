require File.dirname(__FILE__) + '/../spec_helper'

describe "ActiveDirect::ActsAsDirect" do

	before(:each) do
    Category.delete_all
    Video.delete_all
		create_records
  end

	def create_records
		params_a = [ {:name => 'category A'} ]
		params_b = [ {:name => 'category B'} ]
		params_c = [ {:name => 'C'} ]
		call_rpc_method_for_category('create', params_a)
		call_rpc_method_for_category('create', params_b)
		call_rpc_method_for_category('create', params_c)
	end

	def call_rpc_method_for_category(method, params)
		post_params = {:action => 'Category', :method => method, :data => params, :type => 'rpc', :tid => 1 }
		do_post post_params
		ActiveSupport::JSON.decode(last_response.body)
	end

  it "should respond to 'acts_as_direct'" do
    Video.should respond_to(:acts_as_direct)
    Category.should respond_to(:acts_as_direct)
  end
  
  it "should have a default direct method : create" do
		Category.count.should == 3
  end

	it "should have a default direct method : update" do
		Category.first.name.should == "category A"
		category_id = Category.first.id
		update_params = [category_id, {:name => 'category name updated'}]
		call_rpc_method_for_category('update', update_params)
		Category.first.name.should == 'category name updated'
  end

	it "should have a default direct method : update_all" do
		update_params = [{:name => 'category name updated'}, "name LIKE '%category%'"]
		call_rpc_method_for_category('update_all', update_params)
		Category.all.first.name.should == 'category name updated'
		Category.all.second.name.should == 'category name updated'
		Category.all.third.name.should == 'C'
  end

  it "should have a default direct method : delete" do
		category_id = Category.first.id
		delete_params =  [category_id]
		call_rpc_method_for_category('delete', delete_params)
		Category.count.should == 2

		category_ids = Category.all.map(&:id)
		delete_params = [ category_ids ]
		call_rpc_method_for_category('delete', delete_params)
		Category.count.should == 0
  end

	it "should have a default direct method : delete_all" do
		delete_params = [" name LIKE '%category%' "]
		call_rpc_method_for_category('delete_all', delete_params)
		Category.count.should == 1
  end

  it "should have a default direct method : exists" do
		exists_params = [Category.first.id]
		json_resp = call_rpc_method_for_category('exists', exists_params)
		json_resp['result'].should == true
		
		exists_params =  [ [" name LIKE ? ", '%category%'] ]
		json_resp = call_rpc_method_for_category('exists', exists_params)
		json_resp['result'].should == true
  end

  it "should have a default direct method : find" do
		params = [ Category.first.id ]
		json_resp = call_rpc_method_for_category('find', params)
		json_resp['result']['id'].should == Category.first.id
  end

	it "should have a default direct method : find_every" do
		params = [ { :conditions => " name LIKE '%category%' "}  ]
		json_resp = call_rpc_method_for_category('find_every', params)
		json_resp['result'].should be_kind_of Array
		json_resp['result'].size == Category.count( :conditions => " name LIKE '%category%' " )
  end

	it "should have a default direct method : first" do
		params = [  ]
		json_resp = call_rpc_method_for_category('first', params)
		json_resp['result']['id'].should == Category.first.id
  end

	it "should have a default direct method : last" do
	  params = [  ]
		json_resp = call_rpc_method_for_category('last', params)
		json_resp['result']['id'].should == Category.last.id
  end

	it "should have a default direct method : all" do
		params = [  ]
		json_resp = call_rpc_method_for_category('all', params)
		json_resp['result'].should be_kind_of Array
		json_resp['result'].size.should == Category.count()

		params = [ { :conditions => " name LIKE '%category%' "}  ]
		json_resp = call_rpc_method_for_category('all', params)
		json_resp['result'].size.should == Category.count(:conditions => " name LIKE '%category%' ")
  end

	it "should have a default direct method : count" do
		params = [  ]
		call_rpc_method_for_category('count', params)
		json_resp = ActiveSupport::JSON.decode(last_response.body)
		json_resp['result'].should == Category.count()
  end

end