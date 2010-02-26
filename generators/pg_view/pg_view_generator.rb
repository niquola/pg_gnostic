class PgViewGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      unless args.size > 0
        puts "require view name"
        exit 1
      end
      parse_args
      m.directory  File.join('db/views')
      m.directory  File.join('app/model/views')
      m.template "view.rb", File.join('db/views',"#{@view_name}.rb"), :assigns=>@assigns
      m.template "model.rb", File.join('app/model/views',"#{@model_file_name}.rb"), :assigns=>@assigns
    end
  end

  def parse_args
    @view_name = args.shift.pluralize
    @model_name = @view_name.singularize
    @model_file_name = @model_name.underscore
    @class_name = @model_name.classify 
    @dependencies = args if args.length > 0
    @assigns = {
      :view_name=>@view_name,
      :class_name=>@class_name,
      :dependencies=>@dependencies
    }
  end
end
