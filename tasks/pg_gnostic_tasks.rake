require 'fileutils'
require 'date'

namespace :pg do
  def get_backup_dir()
    dir = PgGnostic.config.backup.path
    dir = File.join(Rails.root,dir) unless dir =~ /^\//
    dir
  end

  desc "Backup database"
  task :backup=>:environment do
    config    = ActiveRecord::Base.configurations[RAILS_ENV || 'production']
    backupdir=get_backup_dir
    FileUtils.mkdir_p backupdir
    date = DateTime.now.to_s.gsub(/[-:T+]/,'_')
    backupfile = File.join(backupdir,"#{config["database"]}_#{date}.sql")

    params={
      'host'=>config["host"],
      'port'=>config["port"],
      'username'=>config["username"]
    }.map{|k,v| "--#{k}=#{v}" if v}.join(' ')
    archiver = PgGnostic.config.backup.archive_command
    puts "Backup #{config["database"]} to #{backupfile}"
    command =  "export PGPASSWORD=#{config["password"]} && pg_dump #{params} -w #{config["database"]} | #{archiver} > #{backupfile}"
    puts "Execute: #{command}"
    system command
    system "ls -lh #{backupfile}"
  end

  desc "Restore database"
  task :restore=>:environment do |args|

    config    = ActiveRecord::Base.configurations[RAILS_ENV || 'production']
    @encoding = config[:encoding] || ENV['CHARSET'] || 'utf8'
    begin
      ActiveRecord::Base.establish_connection(config.merge('database' => 'postgres', 'schema_search_path' => 'public'))
      ActiveRecord::Base.connection.create_database(config['database'], config.merge('encoding' => @encoding))
      ActiveRecord::Base.establish_connection(config)

      file = ENV["PGBACKUP"]
      config    = ActiveRecord::Base.configurations[RAILS_ENV || 'development']
      backupdir = get_backup_dir 
      if file && File.exists?(file)
        file = file
      elsif file && File.exists?(File.join(backupdir,file))
        file = File.join(backupdir,file)
      else
        STDOUT.puts "Select which backup file to restore:"
        files = Dir["#{backupdir}/*"].to_a
        files.each_with_index{|f,i| STDOUT.puts "#{i}: #{f}"}
        print "> "
        num = STDIN.gets
        file = files[num.to_i]
      end
      exit unless file && File.exists?(file)
      puts "Restoring database #{config["database"]} from file #{file}"
      params={
        'host'=>config["host"],
        'port'=>config["port"],
        'username'=>config["username"]
      }.map{|k,v| "--#{k}=#{v}" if v}.join(' ')
      unarchiver = PgGnostic.config.backup.unarchive_command 
      command =  "export PGPASSWORD=#{config["password"]} && #{unarchiver} #{file} | psql #{params} -w #{config["database"]}"
      puts "Execute: #{command}"
      system command
      puts "Restore complete!"

    rescue
      $stderr.puts "It seems database #{config["database"]} already exists. Please drop it by hands (rake db:drop) before restore backup."
      $stderr.puts $!
    end
  end

  desc "drop views"
  task :drop_views=>:environment do
    #ActiveRecord::Base.logger=Logger.new STDOUT
    PgGnostic::ViewDefinition.clear_declarations
    PgGnostic::ViewDefinition.load_declarations(File.join(Rails.root,'db','views'))
    PgGnostic::ViewDefinition.delete_all
  end

  desc "update views"
  task :views=>:environment do
    #ActiveRecord::Base.logger=Logger.new STDOUT
    PgGnostic::ViewDefinition.clear_declarations
    PgGnostic::ViewDefinition.load_declarations File.join(Rails.root,'db','views')
    PgGnostic::ViewDefinition.update
  end

  desc "updates functions"
  task :functions => [:environment] do
    Dir["#{File.join(Rails.root,'db','functions')}/*.sql"].sort.each do |f|
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
