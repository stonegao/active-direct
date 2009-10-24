module ActiveDirect
  class Action < Struct.new(:model, :method, :parameters, :tid)
    
  end
end