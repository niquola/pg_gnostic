$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'kung_figure'
# PgGnostic
module PgGnostic
  VERSION = "0.0.4"
  include KungFigure

  autoload :ViewDefinition, 'pg_gnostic/view_definition'
  autoload :Config, 'pg_gnostic/config'

  class << self
    def define
      yield ViewDefinition
    end
  end
end

