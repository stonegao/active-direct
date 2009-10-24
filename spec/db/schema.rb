ActiveRecord::Schema.define :version => 0 do
  create_table "videos", :force => true do |t|
    t.string   :content
    t.integer  :category_id
  end
  
  create_table "categories", :force => true do |t|
    t.string   :name
  end
end
