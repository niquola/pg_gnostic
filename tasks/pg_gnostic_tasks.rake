puts "loading task"
namespace :pg do
  desc "drop views"
  task :drop_views=>:environment do
    #ActiveRecord::Base.logger=Logger.new STDOUT
    PgGnostic::ViewDefinition.load_declarations(File.join(RAILS_ROOT,'db','views'))
    PgGnostic::ViewDefinition.delete_all
  end
  desc "update views"
  task :views=>:environment do
    #ActiveRecord::Base.logger=Logger.new STDOUT
    PgGnostic::ViewDefinition.load_declarations File.join(RAILS_ROOT,'db','views')
    PgGnostic::ViewDefinition.update
  end
  desc "updates functions"
  task :functions => [:environment] do
    Dir["#{File.join(RAILS_ROOT,'db','functions')}/*.sql"].sort.each do |f|
      begin
        puts "execute #{f}"
        sql=open(f,'r').readlines.join("\n")
        ActiveRecord::Base.connection().execute sql;
      rescue Exception=>e
        puts e
      end
    end
  end
  desc "updates functions and views"
  task :update=>[:functions,:views] do
  end
end
