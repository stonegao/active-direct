require File.dirname(__FILE__) + '/../spec_helper'


describe "ActiveDirect::Config" do
  it "should have two models" do
    ["Video", "Category"].each do |model|
      ActiveDirect::Config.has_model?(model).should be_true
    end
  end

  it "should have default direct methods" do
    ActiveDirect::ActsAsDirect::DEFAULT_METHODS.each_key do |method|
      ["Video", "Category"].each do |model|
        ActiveDirect::Config.has_method?(model, method).should be_true
      end
    end
  end
  
  it "should have custom direct methods" do
    model = 'Video'
    custom_methods = ['create_attachment', 'direct_method']
    custom_methods.each do |method|
      ActiveDirect::Config.has_method?(model, method).should be_true
    end
  end
  
  it "should have custom direct method (formHandler)" do
    model = 'Video'
    method_name = 'create_attachment'
    ActiveDirect::Config.method_config[model].any? { |m| m['name'] == method_name && m[:formHandler] == true}.should be_true
  end
  
end