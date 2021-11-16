---
to:  <%= root_path %>/script.sh
---

#!/bin/bash

    #Declare variables

<% for(var i = 0; i < qty_variables; i++) { -%>
export <%= eval(`variable_name_${i+1}`).toUpperCase() %>="$(grep <%= eval(`variable_name_${i+1}`).toUpperCase() %> .env | cut -d '=' -f2)"
<% } -%>

    #Execute the aws command
    echo -e '\n\n----- Iniciando la creación de la invalidación -----\n\n'
    sleep 1
    if aws cloudfront create-invalidation --distribution-id "$DISTRIBUTION" --paths "/*"; then
        echo -e '\n\n----- La invalidación fue creada correctamente -----\n\n'
        sleep 1
    else
        echo -e '\n\n----- Ha ocurrido un error al crear la invalidación -----\n\n'
        sleep 1
        exit 1
    fi
