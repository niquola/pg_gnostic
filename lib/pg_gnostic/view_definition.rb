require 'erb'
require 'active_record'

module PgGnostic
  class TableDesc
    def column_names
      @columns || @columns = ActiveRecord::Base.connection.columns(@name).map{|c| c.name}
      @columns
    end
    def initialize(name)
      @name = quote_table_name(name)
    end

    def quote_table_name(table)
      ActiveRecord::Base.connection.quote_table_name(table)
    end

    def *(opts={})
      table_name = opts[:table_name] || @name
      aliases = opts[:aliases]
      fields = column_names
      fields = fields - opts[:exclude].flatten if opts[:exclude]
      fields.map do |f|
        line="#{table_name}.#{f}"
        line<< " AS #{aliases[f]}" if aliases && aliases[f]
        line
      end.join("\n,")
    end
  end

  class Tables
    attr :sql,true
    def pname
      %Q[format_name(patients.name)]
    end

    def timestamps
      ['created_at','updated_at']
    end

    def method_missing(name)
      return ViewDefinition.predifined_fields[name] if ViewDefinition.predifined_fields[name]
      return TableDesc.new(name)
    end
  end

  class ViewDefinition
    class << self
      attr :views
      def views
        @views||={}
      end

      def load_declarations(path)
        Dir["#{path}/*.rb"].each do |f|
          load f
        end
        Dir["#{path}/*.sql"].each do |f|
          sql = IO.readlines(f,'').to_s
          view_name = File.basename(f,".sql").to_sym
          create_view(view_name,:sql=>sql)
        end
      end

      def create_view(name,opts={})
        raise "View with name #{name} already registered" if views.key? name
        opts[:depends_on] = to_arr opts[:depends_on] if opts.key? :depends_on

        views[name] = opts.merge(:name=>name,:sql=>opts[:sql])
      end

      def predifined_fields
        @predifined_fields ||={}
      end

      def named_fields(*args)
        key = args.shift
        predifined_fields[key]=args.to_a
      end

      def to_arr(val)
        if val && !val.is_a?(Array)
          [ val ]
        else
          val
        end
      end

      def create_view_sql(vname,sql)
        <<-SQL
        CREATE VIEW #{vname} AS #{sql};
        SQL
      end

      def reset_created_flag
        views.values.each {|v| v[:created] = false}
      end

      def delete_all
        views.each do |name,view|
          delete name
        end
      end

      def delete(name)
        puts " * Drop view #{name}"
        ActiveRecord::Base.connection.execute "DROP VIEW IF EXISTS #{name} CASCADE;"
      end

      def update
        delete_all
        reset_created_flag
        views.values.each do |view|
          execute(view,[])
        end
      end

      def execute(view,stack)
        if stack.include?(view)
          stack<< view
          raise "e[31mERROR: Recursion in views dependencies \n #{stack.to_yaml}e[0m"
        end
        return if view[:created]

        if view.key? :depends_on
          view[:depends_on].each do |dep|
            if views.key?(dep)
              stack<< view
              execute views[dep], stack
            else
              raise "e[31mERROR: Could not find dependency #{dep}e[0m"
            end
          end
        end
        execute_sql(view)
        view[:created] = true
      end

      def execute_sql(view)
        name = view[:name]
        ActiveRecord::Base.connection.reconnect!
        template = ERB.new view[:sql]
        t = Tables.new
        t.instance_eval do
          @sql = template.result(binding)
        end
        sql = create_view_sql(view[:name],t.sql)
        puts " * Create view #{name}"
        ActiveRecord::Base.transaction do
          ActiveRecord::Base.connection().execute sql;
        end
      rescue Exception=>e
        puts "e[31mERROR: While creating #{name} #{e}e[0m"
        raise e
      end

    end
  end
end
