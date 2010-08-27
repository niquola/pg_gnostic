require File.dirname(__FILE__) + '/test_helper.rb'
#ActiveRecord::Base.logger=Logger.new(STDOUT)

TestDbUtils.ensure_schema
PgGnostic::ViewDefinition.load_declarations path('db/views')
PgGnostic::ViewDefinition.update

class User < ActiveRecord::Base
  set_table_name "view_#{table_name}"
end

class OtherUser < ActiveRecord::Base
end

class PgGnosticViewUtilsTest < ActiveSupport::TestCase
  def assert_contain_field(model_class, field)
    assert_block "Model #{model_class} not include #{field},but should do. [#{model_class.column_names}]" do
      model_class.column_names.include?(field)
    end
  end

  def assert_not_contain_field(model_class, field)
    assert_block "Model #{model_class} include #{field}, but should not" do
      ! model_class.column_names.include?(field)
    end
  end

  def test_view_creation
    assert_equal 'view_users',User.table_name
    assert_contain_field(User,'name')
    assert_not_contain_field(User,'id')
    assert_not_contain_field(User,'created_at')
    assert_not_contain_field(User,'crypted_password')
    assert_not_contain_field(User,'deleted_at')
  end

  def test_sql_view
    assert_equal 'other_users',OtherUser.table_name
    assert_contain_field(OtherUser,'name')
    assert_not_contain_field(OtherUser,'id')
    assert_not_contain_field(OtherUser,'created_at')
    assert_not_contain_field(OtherUser,'crypted_password')
    assert_not_contain_field(OtherUser,'deleted_at')
  end

  def test_clear_definitions
    pg = PgGnostic::ViewDefinition
    assert( pg.views.length > 0, 'ensure we have declarations')
    pg.clear_declarations
    assert( pg.views.length == 0, 'must be clear')
    pg.load_declarations path('db/views')
    assert( pg.views.length > 0, 'ensure we load them again')
  end
end
