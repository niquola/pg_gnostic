require File.dirname(__FILE__) + '/test_helper.rb'

class PgGnosticViewUtilsTest < ActiveSupport::TestCase
  def test_default_config
    assert_equal('Views',PgGnostic.config.view_model.nest_in_module)

    PgGnostic.configure do
      view_model do
        nest_in_module 'OtherModule'
      end
    end
    assert_equal('OtherModule',PgGnostic.config.view_model.nest_in_module)
    assert_equal('view_',PgGnostic.config.view_model.prefix_view_name)
    
    PgGnostic.clear_config!
  end
end
