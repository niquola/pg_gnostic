require File.dirname(__FILE__) + '/test_helper.rb'

class PgGnosticViewUtilsTest < ActiveSupport::TestCase
  def test_default_config
    assert_equal('Views',PgGnostic.config.view_model.nest_in_module)
    assert_equal('db/backup',PgGnostic.config.backup.path)
    assert_equal('gzip',PgGnostic.config.backup.archive_command)
    assert_equal('gunzip -c',PgGnostic.config.backup.unarchive_command)

    PgGnostic.configure do

      view_model do
        nest_in_module 'OtherModule'
      end

      backup do
        path '/tmp/backups'
        archive_command 'arch'
        unarchive_command 'unarch'
      end

    end
    assert_equal('OtherModule',PgGnostic.config.view_model.nest_in_module)
    assert_equal('view_',PgGnostic.config.view_model.prefix_view_name)
    assert_equal('/tmp/backups',PgGnostic.config.backup.path)
    assert_equal('arch',PgGnostic.config.backup.archive_command)
    assert_equal('unarch',PgGnostic.config.backup.unarchive_command)

    PgGnostic.clear_config!
  end
end
