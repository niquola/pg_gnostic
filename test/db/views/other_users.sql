SELECT
<%= users.* :exclude=>[timestamps,'id',my_exclude_fields] %>
FROM users
