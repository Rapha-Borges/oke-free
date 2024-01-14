#!/usr/bin/env bash

# t_init
# terraform init
t_init(){
     if ! [[ -d ./.terraform ]]; then
        echo terraform init - execution
        terraform init
    fi
}

# t_plan
# verify errors and suggest some action to solve it.
t_plan(){
    terraform plan -out=tfplan &> output-gen-plan
    check_error_handler "401-NotAuthenticated" "Verifique se está logado. Execute: oci session authenticate --region us-ashburn-1" output-gen-plan
}

# t_apply
# terraform apply to cluster handler
t_apply(){
     terraform apply -auto-approve &> output-gen-apply
     if [[ $? -eq 0 ]]; then
        echo "apply with sucess"
        exit 0;
     fi
     check_error_handler "CompartmentAlreadyExist" "Verifique se já existe compartment, exclua, espere e retente." output-gen-apply
     
}

# ssh_handler
# generating and export var
ssh_handler(){
    if ! [[ -f id_rsa.pub ]]; then
        echo "generating rsa key"
        ssh-keygen -t rsa -b 4096 -f id_rsa
    fi
}

# check_error_handler
# handler error
check_error_handler(){
    err="$1"
    message="$2"
    file=$3

    grep $err $file
    if [[ $? -eq 0 ]]; then
        echo
        echo "$message";
        exit -1;
    fi
}

# refresh_token
# to keep alive auth
refresh_token(){
    oci session refresh --config-file ~/.oci/config --profile DEFAULT --auth security_token
}

# t_retry_apply
# retry apply terraform until succeded
t_retry_apply(){
    echo terraform apply - execution
    retry_sleep=10;

    while [[ true ]]; do
        t_plan
        t_apply

        echo "retry terraform apply... retrying in " $retry_sleep " seconds"
        sleep $retry_sleep
        refresh_token
    done
}

# main program
main (){
    ssh_handler
    t_init
    t_retry_apply
}

# vars
export OCI_CLI_AUTH=security_token
export TF_VAR_ssh_public_key=$(cat id_rsa.pub)

main
