module Views
  class <%= class_name %> < ActiveRecord::Base 
    self.table_name_prefix =  "view_"
  end
end
