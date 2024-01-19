export TF_VAR_ssh_public_key=$(cat id_rsa.pub)
export TF_VAR_ssh_private_key=$(cat id_rsa)
export TF_VAR_tenancy_ocid=<your tenancy ocid>
export TF_VAR_user_ocid=<your user ocid>
export TF_VAR_fingerprint=<your fingerprint>
export TF_VAR_private_key_path=<path to your private key>
