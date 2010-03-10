module PgGnostic
  class Config < KungFigure::Base
    class ViewModel < KungFigure::Base
      define_prop :nest_in_module,'Views'
      define_prop :prefix_view_name,'view_'
      def model_path
        nest_in_module ? "app/model/#{nest_in_module.underscore}" : "app/model"
      end
    end
  end
end
