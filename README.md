# Criando um Cluster Kubernetes na OCI usando Terraform

Crie uma conta gratuita na Oracle Cloud, e provisione um cluster Kubernetes gerenciado (OKE) usando o Terraform de forma simples e rápida.

## Oferta Especial #MêsDoKubernetes

### Criando uma conta gratuita na Oracle Cloud

1. Todos terão acesso a um tenant individual para execução do lab. Para ativar o ambiente, acesse este [link e crie a sua conta.](https://signup.cloud.oracle.com/) 

IMPORTANTE:
- No cadastro o País/Território será Brazil mas a Home Region do seu cadastro será "US East-Ashburn”.
- Utilizem o mesmo e-mail que vocês usaram para se inscrever no evento, pois habilitamos uma oferta gratuita nesses e-mails. Caso já tenham uma conta OCI neste e-mail nos enviem um novo e-mail que habilitaremos outra oferta para vocês.
- No cadastro não coloque o nome da empresa, pois ao colocar será necessário o CNPJ.
- Se você já tiver um trial (acesso a nuvem da Oracle) ativo nesse email, você irá conseguir realizar o lab pois serão utilizados recursos always free, porém não terá os 500 dólares sem cartão pois um valor de testes já foi disponibilizado nos 30 dias da ativação.

### Variáveis de ambiente personalizadas para o lab

```
region = us-ashburn-1

shape = VM.Standard.E3.Flex

memory_in_gbs_per_node = 1

image_id = ocid1.image.oc1.iad.aaaaaaaazi34xyxv6og7qgn3nqvaykfvg5ntkkx7yhlkjzpn4z45l72l53wa

node_size = 1
```

## Instalando o Terraform

### - Linux

```
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

```
bash -c "$(curl -L https://raw.githubusercontent.com/oracle/oci-cli/master/scripts/install/install.sh)"
```

2. Quando solicitado para atualizar a variável PATH, digite `yes` e ele atualizará automaticamente seu arquivo .bashrc ou .bash_profile para você. Se você usar um shell diferente, precisará informar o caminho para o OCI CLI (por exemplo, ~/zshrc).

3. Reinicie sua sessão no terminal.

4. Verifique a instalação.

```
oci -v
```

### - Windows

1. Faça download do instalador MSI da CLI do OCI para Windows no GitHub [Releases](https://github.com/oracle/oci-cli/releases)

2. Execute o instalador e siga as instruções.

## Configurando o OCI CLI

1. Execute o comando de configuração.

```
oci session authenticate --region us-ashburn-1
```

2. Exporte o token de autenticação.

- Linux

```
export OCI_CLI_AUTH=security_token
```

- Windows

```
set OCI_CLI_AUTH=security_token
```

3. Verifique se a configuração foi realizada com sucesso.

```
oci session validate --config-file ~/.oci/config --profile DEFAULT --auth security_token
```

## Criando o cluster

1. Clone o repositório.

```
git clone https://github.com/Rapha-Borges/oci-k8s.git
```

2. Dentro do diretório do projeto, gere a chave SSH e adicione o valor da chave pública na TF_VAR.

```
ssh-keygen -t rsa -b 4096 -f id_rsa
```

```
export TF_VAR_ssh_public_key=$(cat id_rsa.pub)
```

3. Valide o tempo de vida do token de autenticação, aconselho que o tempo de vida seja maior que 30 minutos.

```
oci session validate --config-file ~/.oci/config --profile DEFAULT --auth security_token
```

Caso o token esteja próximo de expirar, faça o refresh do token e exporte novamente.

```
oci session refresh --config-file ~/.oci/config --profile DEFAULT --auth security_token
```

```
export OCI_CLI_AUTH=security_token
```

4. Inicialize o Terraform.

```
terraform init
```

5. Crie o cluster.

```
terraform apply
```

6. Acesse o cluster.

```
kubectl get nodes
```

## Load Balancer

O cluster que criamos já conta com um Network Load Balancer configurado para expor uma aplicação na porta 80. Basta configurar um serviço do tipo `NodePort` com a porta `80` e a nodePort `30080`. Exemplos de como configurar o serviço podem ser encontrados no diretório `manifests`.

O endereço do Load Balancer é informado na saída do Terraform, no formato `public_ip = "xxx.xxx.xxx.xxx"` e pode ser consultado a qualquer momento com o comando:

```
terraform output public_ip
```

## Deletando o cluster

1. Para deletar o cluster bastar executar o comando:

```
terraform destroy
```

## Problemas conhecidos

- ### Se você tentar criar um cluster com uma conta gratuita e receber o erro abaixo:

```
Error: Error creating cluster: clusters.clustersClient#CreateCluster: Failure sending request: StatusCode=400 -- Original Error: autorest/azure: Service returned an error. Status=<nil> Code="OutOfCapacity" Message="Out of capacity"
```

As contas gratuitas tem um número limitado de instâncias disponíveis, possivelmente a região que você está tentando criar o cluster não tem mais instâncias disponíveis. Você pode tentar criar o cluster em outra região ou fazer o upgrade para uma conta `Pay As You Go`.Você não será cobrado pelo uso de recursos gratuitos mesmo após o upgrade. 

- ### Erro `401-NotAuthenticated` ou o comando `kubectl` não funciona. Isso ocorre porque o token de autenticação expirou.

Gere um novo token de autenticação e exporte para a variável de ambiente `OCI_CLI_AUTH`.

```
oci session authenticate --region us-ashburn-1
```

* Linux
```
export OCI_CLI_AUTH=security_token
```	

* Windows

```
set OCI_CLI_AUTH=security_token
```

# Referências

- [Terraform Documentation](https://www.terraform.io/docs/index.html)
- [Terrafom Essentials](https://www.linuxtips.io/course/terraform-essentials)
- [Free Oracle Cloud Kubernetes cluster with Terraform](https://arnoldgalovics.com/oracle-cloud-kubernetes-terraform/)