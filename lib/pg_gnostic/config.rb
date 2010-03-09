module PgGnostic
  class ConfigBase
    class << self
      def define_prop(name,default)
        define_method(name) do |*args|
          @props ||= {}
          if args.length > 0
            @props[name] = args[0]
          else
            @props[name] || default
          end
        end
      end
    end
    def method_missing(key,&block)
      @props ||= {}
      child_cfg_clazz = self.class.const_get(key.to_s.camelize.to_sym)
      raise "No such configuration #{key}" unless child_cfg_clazz

      unless @props.key?(key)
        @props[key] = child_cfg_clazz.new
      end
      @props[key].instance_eval(&block) if block_given?

      return @props[key]
    end
  end

  class Config < ConfigBase
    class ViewModel < ConfigBase
      define_prop :mod,'Views'
    end
  end
end
