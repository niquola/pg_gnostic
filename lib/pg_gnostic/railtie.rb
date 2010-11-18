require 'rails/railtie'

module PgGnostic
  class Railtie < Rails::Railtie
    generators do
      require File.expand_path(File.join(File.dirname(__FILE__), '../../rails/generators/pg_view/pg_view_generator'))
    end

    rake_tasks do
      load File.expand_path(File.join(File.dirname(__FILE__),'../..','tasks','pg_gnostic_tasks.rake'))
    end
  end
end