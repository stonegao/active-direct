class Video < ActiveRecord::Base
  acts_as_direct :direct_method => 0, :create_attachment => {:formHandler => true, :len => 1}
  belongs_to :category
  
  def self.create_attachment(args = {})
  end
  
  def self.direct_method
  end
end

class Category < ActiveRecord::Base
  acts_as_direct 
  has_many :videos
  
end
