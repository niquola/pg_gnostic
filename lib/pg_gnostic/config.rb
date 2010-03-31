module PgGnostic
  class Config < KungFigure::Base

    class Backup < KungFigure::Base
      define_prop :path, 'db/backup'
      define_prop :archive_command, 'gzip'
      define_prop :unarchive_command, 'gunzip -c'
    end

    class ViewModel < KungFigure::Base
      define_prop :nest_in_module,'Views'
      define_prop :prefix_view_name,'view_'
      def model_path
        nest_in_module ? "app/model/#{nest_in_module.underscore}" : "app/model"
      end
    end

  end
end
