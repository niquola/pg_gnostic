require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))

if GeneratorTest.respond_to? :generate
  class PgGnosticViewsGeneratorTest < GeneratorTest
    def test_generates_definition
      PgGnostic.clear_config!
      generate 'pg_view', 'users', 'roles'
      assert_file 'db/views/users.rb'
      result = read 'db/views/users.rb'
      assert_match(/view_users/, result)
      assert_match(/view_roles/, result)
      assert_match(/PgGnostic.define/, result)
      assert_match(/depends_on/, result)
      assert_file 'app/model/views/user.rb'
      result = read 'app/model/views/user.rb'
      assert_match(/class User < ActiveRecord::Base/, result)

      generate 'pg_view', 'roles', '--format', 'sql'
      assert_file 'db/views/roles.sql'
      result = read 'db/views/roles.sql'
      assert_file 'app/model/views/role.rb'
      result = read 'app/model/views/role.rb'
      assert_match(/class Role < ActiveRecord::Base/, result)
    end

    def test_gen_with_changed_config
      PgGnostic.clear_config!
      PgGnostic.config.view_model.nest_in_module 'PgViews'
      generate 'pg_view', 'users', 'roles'
      assert_file 'app/model/pg_views/user.rb'
      result = read 'app/model/pg_views/user.rb'
      assert_match(/module PgViews/, result)

      PgGnostic.configure do
        view_model do
          nest_in_module ''
        end
      end
      generate 'pg_view', 'users', 'roles'
      assert_file 'app/model/user.rb'
      result = read 'app/model/user.rb'
      assert_no_match(/module/, result)
    end
  end
end