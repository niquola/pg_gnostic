$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'kung_figure'
# PgGnostic
module PgGnostic
  VERSION = "0.1.0"
  include KungFigure

  autoload :ViewDefinition, 'pg_gnostic/view_definition'
  autoload :Config, 'pg_gnostic/config'

  require 'pg_gnostic/railtie'

  class << self
    def define
      yield ViewDefinition
    end
  end
end

