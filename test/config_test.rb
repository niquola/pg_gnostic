require File.dirname(__FILE__) + '/test_helper.rb'


class PgGnosticViewUtilsTest < ActiveSupport::TestCase
  def test_default_config
    assert_equal('Views',PgGnostic.config.view_model.mod)

    PgGnostic.configure do
      view_model do
        mod 'OtherModule'
      end
    end
    assert_equal('OtherModule',PgGnostic.config.view_model.mod)
  end
end
