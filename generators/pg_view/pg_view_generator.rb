class PgViewGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.directory  File.join('db/views')
    end
  end
end
