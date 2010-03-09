$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
# PgGnostic
module PgGnostic
  autoload :ViewDefinition, 'pg_gnostic/view_definition'
  autoload :View, 'pg_gnostic/view'
  autoload :Config, 'pg_gnostic/config'

  class << self
    def define
      yield ViewDefinition
    end

    def config 
      @config||=Config.new
    end

    def configure(&block)
      config.instance_eval &block
    end

    def load_config(path)
      load path
    end
  end
end

