require 'pg_gnostic'

class PgViewGenerator < Rails::Generators::Base
  desc "Generates pg view file"
  class_option :format, :default => 'ruby', :aliases => "-f", :banner => 'sql | ruby'
  argument :view_name, :required => true, :banner => "view name"
  argument :dependencies, :type => :array, :required => false, :banner => "depends on views"
  source_root File.dirname(__FILE__)

  attr_reader :nest_in_module, :class_name, :dependencies, :prefix_view_name

  def init_parameters
    @view_name        = self.view_name
    @model_name       = @view_name.singularize
    @model_file_name  = @model_name.underscore
    @class_name       = @model_name.classify
    @dependencies     = self.dependencies
    @nest_in_module   = PgGnostic.config.view_model.nest_in_module
    @prefix_view_name = PgGnostic.config.view_model.prefix_view_name
  end

  def generate
    model_path = PgGnostic.config.view_model.model_path
    FileUtils.mkdir_p 'db/views'
    FileUtils.mkdir_p model_path
    case options[:format]
      when 'sql'
        template "templates/view.sql", File.join('db/views', "#{@view_name}.sql")
      when 'ruby'
        template "templates/view.rb", File.join('db/views', "#{@view_name}.rb")
    end
    template "templates/model.rb", File.join(model_path, "#{@model_file_name}.rb")
  end
end
