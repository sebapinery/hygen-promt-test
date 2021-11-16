---
to:  <%= root_path %>/run.sh
---

#!/bin/bash

set -e

    #Configure the aws cli with aws credentials
    aws configure set aws_access_key_id "@option.aws_stg_access_key_id@" && \
    aws configure set aws_secret_access_key "@option.aws_stg_secret_access_key@"

    #Configure kubectl to work with the timejobs-staging cluster
    echo -e '\n\n----- Configurando contexto de kubectl -----\n\n'
    aws eks --region us-east-1 update-kubeconfig --name timejobs-staging

    #Create rundeck-worker pod
    echo -e '\n\n----- Creando rundeck-worker pod -----\n\n'
    WORKER_NAME="rundeck-worker-$(date +%H%M%S)"
    sed -e "s|\${worker_name}|$WORKER_NAME|" \
        /home/rundeck/projects/aws/worker/aws-worker.yaml | kubectl apply -f - -n rundeck-jobs
    
    #waiting for the rundeck-worker pod to be ready
    echo -e '\n\n----- Verificando el estado de '$WORKER_NAME' -----\n\n'
    COUNT=1
    while [ true ]; do
        sleep 5s
        if [ $(kubectl get pod -n rundeck-jobs $WORKER_NAME | awk '{print $3}' | tail -n +2) == "Running" ]; then
            echo -e ''$WORKER_NAME' levantado correctamente'
            break;
        elif [ $COUNT -gt 9 ]; then
            echo -e '\n\n----- '$WORKER_NAME' supero el tiempo máximo de creación ('$COUNT'/10) -----\n\n'
            echo -e '\n\n----- Diagnosticando '$WORKER_NAME' -----\n\n'
            kubectl describe pod $WORKER_NAME -n rundeck-jobs
            echo -e '\n\n----- Eliminando '$WORKER_NAME' -----\n\n'
            kubectl delete pod $WORKER_NAME -n rundeck-jobs --grace-period 0 --force
            exit 1;
        fi
        echo -e '\n----- Esperando a '$WORKER_NAME' ('$COUNT'/10) -----\n'
        COUNT=$(($COUNT+1))
    done

    #Copy .env.example like .env
    cp /home/rundeck/projects/<%= root_path %>/.env.example /home/rundeck/projects/<%= root_path %>/.env

    #remplace variables on .env
<% for(var i = 0; i < qty_variables; i++) { -%>
    sed -i "s|__<%= eval(`variable_name_${i+1}`).toUpperCase() %>__|@option.<%= eval(`variable_name_${i+1}`).toUpperCase() %>@|" /home/rundeck/projects/<%= root_path %>/.env
<% } -%>

    #Copy script file on rundeck-worker pod
    echo -e '\n\n----- Copiando archivos de ejecución en '$WORKER_NAME' -----\n\n'
    kubectl cp /home/rundeck/projects/<%= root_path %>/script.sh rundeck-jobs/$WORKER_NAME:/home/worker/job.sh
    kubectl cp /home/rundeck/projects/<%= root_path %>/.env rundeck-jobs/$WORKER_NAME:/home/worker/.env
    
    #Remove .env file
    rm -rf /home/rundeck/projects/<%= root_path %>/.env

    #Execute the script on rundeck-worker pod
    if kubectl exec -ti -n rundeck-jobs $WORKER_NAME -- /home/worker/job.sh; then
        #Delete rundeck-worker pod
        echo -e '\n\n----- Eliminando '$WORKER_NAME' -----\n\n'
        kubectl delete pod $WORKER_NAME -n rundeck-jobs --grace-period 0 --force
    else
        echo -e '\n\n----- Ha ocurrido un error en la ejecución del trabajo -----\n\n'
        #Delete rundeck-worker pod
        echo -e '\n\n----- Eliminando '$WORKER_NAME' -----\n\n'
        kubectl delete pod $WORKER_NAME -n rundeck-jobs --grace-period 0 --force
        exit 1
    fi




