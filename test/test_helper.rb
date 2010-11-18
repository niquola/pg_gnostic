require 'rubygems'
require 'kung_figure'

def path(path)
  File.join(File.dirname(__FILE__), path).to_s
end

$:.unshift(path('../lib'))
require "test/unit"
require 'pg_gnostic'
require 'active_support'
require 'active_support/test_case'
require "active_record"
require 'rails'
require "rails/generators"

#Test::Unit.run = true

GEM_ROOT= path('..')

class GeneratorTest < ActiveSupport::TestCase
  def read(path)
    [IO.readlines("#{fake_rails_root}/#{path}", '')].flatten.join
  end

  def assert_file(file)
    assert_block "File #{file} not exists, as not expected" do
      File.exists? "#{fake_rails_root}/#{file}"
    end
  end

  def setup
    FileUtils.rm_r(fake_rails_root)
    FileUtils.mkdir_p(fake_rails_root)
  end

  protected
  def fake_rails_root
    path('rails_root')
  end
end

class TestDbUtils
  class<< self
    def config
      @config ||= YAML::load(IO.read(path('/database.yml'))).symbolize_keys
    end

    #create test database
    def ensure_test_database
      connect_to_test_db
    rescue
      create_database
    end

    def load_schema
      ensure_test_database
      load(path('db/schema.rb'))
    end

    def ensure_schema
      load_schema
    rescue
      puts "tests database exists: skip schema loading"
    end

    def create_database
      connect_to_postgres_db
      ActiveRecord::Base.connection.create_database(config[:database], config)
      connect_to_test_db
    rescue
      $stderr.puts $!, *($!.backtrace)
      $stderr.puts "Couldn't create database for #{config.inspect}"
    end

    def connect_to_test_db
      ActiveRecord::Base.establish_connection(config)
      ActiveRecord::Base.connection
    end

    def connect_to_postgres_db
      ActiveRecord::Base.establish_connection(config.merge(:database => 'postgres', :schema_search_path => 'public'))
    end

    def drop_database
      connect_to_postgres_db
      ActiveRecord::Base.connection.drop_database config[:database]
    end
  end
end