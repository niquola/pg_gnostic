PgGnostic.define do |d|
  d.create_view :view_users,:depends_on=>[:view_roles], :sql=><<-SQL
  SELECT
  fld0
  ,fld1
  ,fld2
  FROM users
  JOIN table2 ON conditions
  SQL
end
# vim:ft=sql
