<% unless nest_in_module.empty? %>
 module <%= nest_in_module %>
<% end %>
  class <%= class_name %> < ActiveRecord::Base 
    <% unless prefix_view_name.empty? %>
       set_table_name "<%= prefix_view_name %>_#{table_name}"
    <% end %>
  end
<% unless nest_in_module.empty? %>
 end
<% end %>
