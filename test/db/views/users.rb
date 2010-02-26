PgGnostic.define do |d|
  d.named_fields :my_exclude_fields,'crypted_password','salt','last_login_datetime','deleted_at'
  d.create_view :view_users, :sql=><<-SQL
  SELECT
  <%= users.* :exclude=>[timestamps,'id',my_exclude_fields] %>
  FROM users
  SQL
end
