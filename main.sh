#!/usr/bin/env bash

oci_auth_cmd="oci session authenticate --region us-ashburn-1 --profile-name DEFAULT"
oci_session_validate_cmd="oci session validate --config-file ~/.oci/config --profile DEFAULT --auth security_token --local 2>&1 | awk '{print \$5,\$6}'"
oci_session_refresh_cmd="oci session refresh --config-file ~/.oci/config --profile DEFAULT --auth security_token"

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
    echo terraform plan - initialized
    terraform plan -out=tfplan &> output-gen-plan
    check_error_handler "401-NotAuthenticated" "Executando comand: $oci_auth_cmd" output-gen-plan "$oci_auth_cmd"
}

# t_apply
# terraform apply to cluster handler
t_apply(){
    echo terraform apply - initialized
    terraform apply -auto-approve &> output-gen-apply
    if [[ $? -eq 0 ]]; then
        echo -e "terraform apply with success\n"
        cat output-gen-apply
        rm -f output-gen-apply
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
    callback_cmd=$4

    grep $err $file | uniq
    if [[ ${PIPESTATUS[0]} -eq 0 ]]; then
        echo -e "\n$message\n";
        rm -f $file
        [ -n "$callback_cmd" ] && eval $callback_cmd || exit -1;
    fi
}

# oci_auth
# oci session authenticate
oci_auth(){
    region=${1:-us-ashburn-1}
    profile_name=${$2:-DEFAULT}
    extra_args=$3
    oci session authenticate --region $region --profile-name $profile_name $extra_args
}

# refresh_token
# to keep alive auth
refresh_token(){
    oci_session_timestamp=$(date -d "$(eval $oci_session_validate_cmd)" +%s)
    current_timestamp=$(date +%s)
    timestamp_diff=$(( oci_session_timestamp - current_timestamp ))

    # Run the oci session auth command if the session has expired.
    [ $timestamp_diff -le 0 ] && $oci_auth_cmd
    # Run the oci session refresh command if the session has 5 minutes or less to expire.
    [ $timestamp_diff -le 300 ] && $oci_session_refresh_cmd
}

# t_retry_apply
# retry apply terraform until succeded
t_retry_apply(){
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
