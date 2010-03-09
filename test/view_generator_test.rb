require File.dirname(__FILE__) + '/test_helper.rb'

class PgGnosticViewsGeneratorTest < GeneratorTest 
  def test_generates_definition
    generate 'pg_view','users','roles'
    assert_file 'db/views/users.rb'
    result = read 'db/views/users.rb'
    assert_match(/view_users/, result)
    assert_match(/view_roles/, result)
    assert_match(/PgGnostic.define/, result)
    assert_match(/depends_on/, result)
    assert_file 'app/model/views/user.rb'
    result = read 'app/model/views/user.rb'
    assert_match(/class User < ActiveRecord::Base/, result)

    generate 'pg_view','roles','--format','sql','dependency_view'
    assert_file 'db/views/roles.sql'
    result = read 'db/views/roles.sql'
    assert_file 'app/model/views/role.rb'
    result = read 'app/model/views/role.rb'
    assert_match(/class Role < ActiveRecord::Base/, result)
  end
end
