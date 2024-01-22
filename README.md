# Criando um Cluster Kubernetes na OCI usando Terraform [#MêsDoKubernetes](https://github.com/linuxtips/MesDoKubernetes)

### EM ATUALIZAÇÃO - VERIFIQUE A [ISSUE #8](https://github.com/Rapha-Borges/oke-free/issues/8) PARA MAIORES INFORMAÇÕES

Crie uma conta gratuita na Oracle Cloud, e provisione um cluster Kubernetes usando o Terraform de forma simples e rápida.

## Oferta Especial [#MêsDoKubernetes](https://github.com/linuxtips/MesDoKubernetes)

### Criando uma conta gratuita na Oracle Cloud

1. Todos terão acesso a um tenant individual para execução do lab. Para ativar o ambiente, acesse este [link e crie a sua conta.](https://signup.cloud.oracle.com/)

IMPORTANTE:

- No cadastro o País/Território será Brazil mas a Home Region do seu cadastro será "US East-Ashburn”.
- Utilizem o mesmo e-mail que vocês usaram para se inscrever no evento, pois habilitamos uma oferta gratuita nesses e-mails. Caso já tenham uma conta OCI neste e-mail nos enviem um novo e-mail que habilitaremos outra oferta para vocês.
- No cadastro não coloque o nome da empresa, pois ao colocar será necessário o CNPJ.
- Se você já tiver um trial (acesso a nuvem da Oracle) ativo nesse email, você irá conseguir realizar o lab pois serão utilizados recursos always free, porém não terá os 500 dólares sem cartão pois um valor de testes já foi disponibilizado nos 30 dias da ativação.

### Variáveis do Terraform personalizadas para o lab

Caso queira realizar o lab com as configurações utilizadas na live, basta substituir as variáveis do Terraform no arquivo `variables.tf` pelas variáveis abaixo. Mas lembre-se, as instâncias criadas com essas configurações só serão gratuitas enquanto os seus créditos oferecidos pela Oracle durante o #MêsDoKubernetes estiverem ativos.

```
region = us-ashburn-1

shape = VM.Standard.A1.Flex

memory_in_gbs_per_node = 2

image_id = ocid1.image.oc1.iad.aaaaaaaao2zpwcb2osmbtliiuzlphc3y2fqaqmcpp5ttlcf573sidkabml7a

node_size = 1

kubernetes_version = v1.28.2
```

## Instalando o Terraform

### - Linux

```sh
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```

### - Windows

1. Baixe o [Terraform](https://www.terraform.io/downloads.html) e descompacte o arquivo em um diretório de sua preferência.

2. Adicione o diretório ao [PATH do Windows](https://www.java.com/pt-BR/download/help/path_pt-br.html).

## Baixando e configurando o OCI CLI

### - Linux

1. Execute o comando de instalação:

```sh
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
```

2. Quando solicitado para atualizar a variável PATH, digite `yes` e ele atualizará automaticamente seu arquivo .bashrc ou .bash_profile para você. Se você usar um shell diferente, precisará informar o caminho para o OCI CLI (por exemplo, ~/zshrc).

3. Reinicie sua sessão no terminal.

4. Verifique a instalação.

```sh
oci -v
```

### - Windows

1. Faça download do instalador MSI da CLI do OCI para Windows no GitHub [Releases](https://github.com/oracle/oci-cli/releases)

2. Execute o instalador e siga as instruções.

## Métodos de Autenticação com a Nuvem OCI

Para este tutorial temos dois métodos de autenticação:

- Baseado em Security Token
- Baseado em API Key

 > OBS é muito importante escolher apenas uma das opções de autenticação.

## Configurando o OCI CLI (Baseado em Security Token)

1. Execute o comando de configuração.

```sh
oci session authenticate --region us-ashburn-1
```

2. Exporte o token de autenticação.

> Use a variável OCI_CLI_AUTH com o valor `security_token`

- Linux

```sh
export OCI_CLI_AUTH=security_token
```

- Windows

```sh
set OCI_CLI_AUTH=security_token
```

3. Verifique se a configuração foi realizada com sucesso.

```sh
oci session validate --config-file ~/.oci/config --profile DEFAULT --auth security_token
```

## Configurando o OCI CLI (Baseado em API Key)

Você pode utilizar a autenticação do tipo `API KEY` para criar e gerenciar o seu cluster. A vantage desse tipo de autenticação é que você não precisa utilizar o `session token`.

1. Crie uma `API key`

- Entre no seu perfil, acesse a aba [API Keys](https://cloud.oracle.com/identity/domains/my-profile/api-keys) e clique em `Add API Key`.

2. Selecione `Generate API key pair`, faça o download da chave privada. Em seguida, clique em `Add`.

3. Após o download, mova a chave para o diretório `~/.oci/` e renomeie para `oci_api_key.pem`.

```
mv ~/Downloads/<nome_do_arquivo>.pem ~/.oci/oci_api_key.pem
```

4. Corrija as permissões da chave privada:

```
oci setup repair-file-permissions --file ~/.oci/oci_api_key.pem
```

5. Copie o texto que apareceu na página de criação da `API KEY` para o arquivo `~/.oci/config`. Não se esqueça de substituir o valor do compo `key_file` pelo caminho da chave privada `~/.oci/oci_api_key.pem`, conforme exemplo abaixo.

```
vim ~/.oci/config
```

> OBS O painel da OCI ao gerar os dados de acesso ela usa o perfil DEFAULT, recomendo criar o seu proprio perfil, ex: MINHA_API_KEY

Não recomendo usar o DEFAULT

```
[DEFAULT]
user=ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fingerprint=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
tenancy=ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
region=xxxxxxxx
key_file=~/.oci/oci_api_key.pem
```

> Criando um novo perfil ex: MINHA_API_KEY

```
[MINHA_API_KEY]
user=ocid1.user.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
fingerprint=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
tenancy=ocid1.tenancy.oc1..xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
region=xxxxxxxx
key_file=~/.oci/oci_api_key.pem
```

> Use a variável OCI_CLI_AUTH com o valor `api_key`

- Linux

```sh
export OCI_CLI_AUTH=api_key
```

- Windows

```sh
set OCI_CLI_AUTH=api_key
```

6. Adicione os valores ao arquivo `export_variables.sh`, para exportar todas as variáveis necessárias para a autenticação do terraform.

```
export TF_VAR_user_ocid=<your user ocid>
export TF_VAR_fingerprint=<your fingerprint>
export TF_VAR_tenancy_ocid=<your tenancy ocid>
export TF_VAR_private_key_path=~/.oci/oci_api_key.pem
export TF_VAR_ssh_private_key=$(cat id_rsa)
export TF_VAR_ssh_public_key=$(cat id_rsa.pub)
export TF_VAR_oci_profile=<DEFAULT ou MINHA_API_KEY>
```

Edite o arquivo `variables.tf` e remova o `#` das variáveis a seguir:

```
# variable "user_ocid" {
#   type    = string
# }

# variable "fingerprint" {
#   type    = string
# }

# variable "tenancy_ocid" {
#   type    = string
# }

# variable "private_key_path" {
#   type    = string
# }

# Deve ficar assim:

variable "user_ocid" {
  type    = string
}

variable "fingerprint" {
  type    = string
}

variable "tenancy_ocid" {
  type    = string
}

variable "private_key_path" {
  type    = string
}

```

Agora rode o script para exportar as variáveis:

```
source export_variables.sh
```

Agora rode o script para ver se deu certo a autenticação baseado em API Key

```
oci iam region list --config-file ~/.oci/config --profile DEFAULT_API_KEY --auth api_key
```

> Se deu certo vai ter uma saída parecida com esse exemplo.

```
{
  "data": [
    {
      "key": "AMS",
      "name": "eu-amsterdam-1"
    },
    {
      "key": "ARN",
      "name": "eu-stockholm-1"
    },
    ...
  ]
}
```

> se apareceu uma lista de todas a regiões então deu certo, siga em frente.

## Instalando seu Kubectl | Kubernetes 1.28.2 |

### GNU/Linux

Kubectl é quem faz a comunicação com a API Kubernetes usando CLI. Devemos usar a mesma versão que está explicita na variáveis do terraform. Veja [variables.tf](variables.tf)

1. Baixando o binário kubectl

```
curl -LO https://dl.k8s.io/release/v1.28.2/bin/linux/amd64/kubectl
```

2. Instalando o binário

```
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
```
3. Adicione kubectl completion bash

```
echo '
source <(kubectl completion bash)' >> ~/.bashrc
```  
4. Valide a versão

```
kubectl version --client
```

- *Note: O comando acima irá gerar um aviso:*
    "WARNING: This version information is deprecated and will be replaced with the output from kubectl version --short."

**Você pode ignorar este aviso. Você está apenas verificando a versão do kubectl que instalou.**

### Windows

1. Baixe o binário kubectl

```
curl.exe -LO "https://dl.k8s.io/release/v1.28.2/bin/windows/amd64/kubectl.exe"
```

2. **Anexe a pasta binária kubectl à sua variável de ambiente PATH.**

3. Valide a versão

```
kubectl version --client --output=yaml
```

**🔗 [Guia de instalação para todos os ambientes](https://kubernetes.io/docs/tasks/tools/)**

## Criando o cluster

1. Clone o repositório.

```sh
git clone https://github.com/Rapha-Borges/oke-free.git
```

2. Dentro do diretório do projeto, gere a chave SSH e adicione o valor da chave pública na TF_VAR.

```sh
ssh-keygen -t rsa -b 4096 -f id_rsa
```

- Linux

```sh
export TF_VAR_ssh_public_key=$(cat id_rsa.pub)
```

- Windows

```
set /p TF_VAR_ssh_public_key=<id_rsa.pub
```

> OBS se o seu método de autenticação escolhido  for baseado em Security Token

3. Valide o tempo de vida do token de autenticação, aconselho que o tempo de vida seja maior que 30 minutos.

```sh
oci session validate --config-file ~/.oci/config --profile DEFAULT --auth security_token
```

Caso o token esteja próximo de expirar, faça o refresh do token e exporte novamente.

```sh
oci session refresh --config-file ~/.oci/config --profile DEFAULT --auth security_token
```

```sh
export OCI_CLI_AUTH=security_token
```

4. Inicialize o Terraform.

```sh
terraform init
```

5. Crie o cluster.

```sh
terraform apply
```

- OBS: Opicionalmente, você pode utilizar o comando `terraform plan` para visualizar as alterações que serão realizadas antes de executar o `terraform apply`. Com os seguintes comandos:

```
terraform plan -out=oci.tfplan
terraform apply "oci.tfplan" -auto-approve
```

6. Acesse o cluster.

```sh
kubectl get nodes
```

### Script para criação do cluster

Caso queira automatizar o processo de criação do cluster, basta executar o script main.sh que está na raiz do projeto. O script irá gerar a chave SSH, adicionar a chave pública na TF_VAR, inicializar o Terraform e criar o cluster.

Atenção: O script está em fase de testes e funciona apenas no Linux.

```sh
./main.sh
```

## Load Balancer

O cluster que criamos já conta com um Network Load Balancer configurado para expor uma aplicação na porta 80. Basta configurar um serviço do tipo `NodePort` com a porta `80` e a nodePort `30080`. Exemplos de como configurar o serviço podem ser encontrados no diretório `manifests`.

O endereço do Load Balancer é informado na saída do Terraform, no formato `public_ip = "xxx.xxx.xxx.xxx"` e pode ser consultado a qualquer momento com o comando:

```sh
terraform output public_ip
```

## Deletando o cluster

1. Para deletar o cluster bastar executar o comando:

```sh
terraform destroy
```

## Problemas conhecidos

- ### Se você tentar criar um cluster com uma conta gratuita e receber o erro abaixo

```
Error: "Out of capacity" ou "Out of host capacity"
```

As contas gratuitas tem um número limitado de instâncias disponíveis, possivelmente a região que você está tentando criar o cluster não tem mais instâncias disponíveis. Você pode esperar até que novas instâncias fiquem disponíveis ou tentar criar o cluster em outra região. Além disso, o upgrade para uma conta `Pay As You Go` pode resolver o problema, pois as contas `Pay As You Go` tem um número maior de instâncias disponíveis. Você não será cobrado pelo uso de recursos gratuitos mesmo após o upgrade.

- ### Erro `401-NotAuthenticated` ou o comando `kubectl` não funciona. Isso ocorre porque o token de autenticação expirou

Gere um novo token de autenticação e exporte para a variável de ambiente `OCI_CLI_AUTH`.

```sh
oci session authenticate --region us-ashburn-1
```

- Linux

```sh
export OCI_CLI_AUTH=security_token
```

- Windows

```sh
set OCI_CLI_AUTH=security_token
```

- ### Erros devido a falha na execução do `terraform destroy`, impossibilitando a exclusão do cluster e todos os recuros. Ou erros como o `Error Code: CompartmentAlreadyExists` que não são resolvidos com o `terraform destroy`

Para resolver esse problema, basta deletar os recursos manualmente no console da OCI. Seguindo a ordem abaixo:

- [Kubernetes Cluster](https://cloud.oracle.com/containers/clusters)
- [Virtual Cloud Networks](https://cloud.oracle.com/networking/vcns)
- [Compartments](https://cloud.oracle.com/identity/compartments)

Obs: Caso não apareça o Cluster ou a VPN para deletar, certifique que selecionou o Compartment certo `k8s`.

> Siga o passo abaixo somente após a criação do cluster com sucesso.

7. Edite o arquivo `~/.kube/config` seguindo o modelo abaixo:

```
- name: user-xxxxxxxxxx
  user:
    exec:
      apiVersion: client.authentication.k8s.io/v1beta1
      command: oci
      args:
      - ce
      - cluster
      - generate-token
      - --cluster-id
      - xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
      - --region
      - xxxxxxxxxxx
      - --auth            # ADICIONE ESSA LINHA
      - api_key           # ADICIONE ESSA LINHA
      - --profile         # ADICIONE ESSA LINHA
      - DEFAULT           # ADICIONE ESSA LINHA
```

# Referências

- [Terraform Documentation](https://www.terraform.io/docs/index.html)
- [Terrafom Essentials](https://www.linuxtips.io/course/terraform-essentials)
- [Free Oracle Cloud Kubernetes cluster with Terraform](https://arnoldgalovics.com/oracle-cloud-kubernetes-terraform/)
