PgGnostic.define do |d|
  d.create_view :view_users,:depends_on=>[:other_users], :sql=><<-SQL
  SELECT
    name, first_name, last_name
  FROM users
  SQL
end
# vim:ft=sql
