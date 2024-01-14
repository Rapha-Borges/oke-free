#!/usr/bin/env bash

# ssh_handler
# generating and export var
ssh_handler(){
    if ! [[ -f id_rsa.pub ]]; then
        echo "generating rsa key"
        ssh-keygen -t rsa -b 4096 -f id_rsa
    fi
}

# check_error
# handler error
check_error(){
    err=$1
    message=$2

    grep $err output-gen
    if [[ $? -eq 0 ]]; then
        echo
        echo "$message";
        exit -1;
    fi
}

# t_init
# terraform init
t_init(){
     if ! [[ -d ./.terraform ]]; then
        echo terraform init - execution
        terraform init
    fi
}

# t_plan
# verify errors and suggest some action to solve it
t_plan(){
    terraform plan -out=tfplan &> output-gen
    check_error "401-NotAuthenticated" "Verifique se está logado. Execute: oci session authenticate --region us-ashburn-1"
    check_error "Error Code: CompartmentAlreadyExists" "Verifique se já existe compartment, exclua, espere e retente."
}

# t_retry_apply
# retry apply terraform until succeded
t_retry_apply(){
    echo terraform apply - execution
    retry_sleep=10;

    while [[ true ]]; do
        t_plan

        terraform apply -auto-approve
        if [[ $? -eq 0 ]]; then
            echo "applied with success!";
            exit 0;
        fi

        echo "retry terraform apply... retrying in " $retry_sleep " seconds"
        sleep $retry_sleep
    done
}

# main program
main (){
    ssh_handler
    t_init
    t_retry_apply
}

# vars
export TF_VAR_ssh_public_key=$(cat id_rsa.pub)

main