require File.dirname(__FILE__) + '/test_helper.rb'

class PgGnosticViewsGeneratorTest < GeneratorTest 
  def test_generates_definition
    generate 'pg_view','users','roles'
    result = read 'db/views/users.rb'
    assert_match(/view_users/, result)
    assert_match(/view_roles/, result)
    assert_match(/PgGnostic.define/, result)
    assert_match(/depends_on/, result)
    result = read 'app/model/views/user.rb'
    assert_match(/class User < PgGnostic::View/, result)
  end
end
