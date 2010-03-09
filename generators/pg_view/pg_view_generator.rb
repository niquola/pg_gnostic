class PgViewGenerator < Rails::Generator::Base
  default_options :format => 'ruby'
  def manifest
    record do |m|
      unless args.size > 0
        puts "require view name"
        exit 1
      end
      parse_args
      m.directory  File.join('db/views')
      m.directory  File.join('app/model/views')
      case options[:format]
      when 'sql':
        m.template "view.sql", File.join('db/views',"#{@view_name}.sql"), :assigns=>@assigns 
      when 'ruby':
        m.template "view.rb", File.join('db/views',"#{@view_name}.rb"), :assigns=>@assigns
      end
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

  protected
  def banner
    "Usage: #{$0} #{spec.name} ViewName"
  end

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("-f","--format=ruby", String, "sql | ruby","Default ruby") { |v| options[:format] = v }
  end
end
