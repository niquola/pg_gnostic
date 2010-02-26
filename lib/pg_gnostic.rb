$:.unshift(File.dirname(__FILE__)) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
# PgGnostic
module PgGnostic
  autoload :ViewDefinition, 'pg_gnostic/view_definition'
  autoload :View, 'pg_gnostic/view'

  class << self
    def define
      yield ViewDefinition
    end
  end
end

