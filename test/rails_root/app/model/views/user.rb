
 module Views

  class User < ActiveRecord::Base 
    
       set_table_name "view__#{table_name}"
    
  end

 end

