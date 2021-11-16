---
to:  <%= root_path %>/.env.example
---

<% for(var i = 0; i < qty_variables; i++) { -%>
    <%= eval(`variable_name_${i+1}`).toUpperCase() %>=__<%= eval(`variable_name_${i+1}`).toUpperCase() %>__
<% } -%>