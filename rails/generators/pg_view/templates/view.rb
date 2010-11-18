PgGnostic.define do |d|
  d.create_view :view_<%= view_name %>,:depends_on=>[<%= dependencies.map{|d| ":view_#{d}"}.join(',') if dependencies %>], :sql=><<-SQL
  SELECT
  fld0
  ,fld1
  ,fld2
  FROM <%= view_name %>
  JOIN table2 ON conditions
  SQL
end
# vim:ft=sql
