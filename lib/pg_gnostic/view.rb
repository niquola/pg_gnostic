require 'active_record'
module PgGnostic
  class View < ActiveRecord::Base
    self.table_name_prefix =  "view_"
    self.abstract_class = true
  end
end
