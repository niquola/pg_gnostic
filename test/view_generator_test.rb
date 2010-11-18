require File.expand_path(File.join(File.dirname(__FILE__), 'test_helper'))
require File.expand_path(File.join(File.dirname(__FILE__), "../rails/generators/pg_view/pg_view_generator"))

class PgGnosticViewsGeneratorTest < GeneratorTest
  def test_generates_definition
    FileUtils.chdir fake_rails_root do
      PgGnostic.clear_config!
      PgViewGenerator.new(['users', 'roles']).invoke_all
      assert_file 'db/views/users.rb'
      result = read 'db/views/users.rb'
      assert_match(/view_users/, result)
      assert_match(/view_roles/, result)
      assert_match(/PgGnostic.define/, result)
      assert_match(/depends_on/, result)
      assert_file 'app/model/views/user.rb'
      result = read 'app/model/views/user.rb'
      assert_match(/class User < ActiveRecord::Base/, result)

      PgViewGenerator.new(['roles'], {:format => 'sql'}).invoke_all
      assert_file 'db/views/roles.sql'
      result = read 'db/views/roles.sql'
      assert_file 'app/model/views/role.rb'
      result = read 'app/model/views/role.rb'
      assert_match(/class Role < ActiveRecord::Base/, result)
    end
  end

  def test_gen_with_changed_config
    FileUtils.chdir fake_rails_root do
      PgGnostic.clear_config!
      PgGnostic.config.view_model.nest_in_module 'PgViews'
      PgViewGenerator.new(['users', 'roles']).invoke_all
      assert_file 'app/model/pg_views/user.rb'
      result = read 'app/model/pg_views/user.rb'
      assert_match(/module PgViews/, result)

      PgGnostic.configure do
        view_model do
          nest_in_module ''
        end
      end
      PgViewGenerator.new(['users', 'roles']).invoke_all
      assert_file 'app/model/user.rb'
      result = read 'app/model/user.rb'
      assert_no_match(/module/, result)
    end
  end
end