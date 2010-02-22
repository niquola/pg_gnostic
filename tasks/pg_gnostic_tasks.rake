puts "loading task"
namespace :pg do
  desc "update db views and functions"
  task :update => :environment do
    puts "ROOT #{RAILS_ROOT}"
    puts 'update views'
  end
end
