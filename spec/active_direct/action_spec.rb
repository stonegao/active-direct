require File.dirname(__FILE__) + '/../spec_helper'

describe "ActiveDirect::Action" do
  before(:all) do
    @action = ActiveDirect::Action.new
  end

  it "should respond to 'model', 'method', 'parameters', 'tid'" do
    [:model, :method, :parameters, :tid].each do |m|
      @action.should respond_to(m)
    end
  end

end