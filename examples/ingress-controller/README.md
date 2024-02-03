# Ingress Nginx com Cert Manager

Neste exemplo, vamos instalar o Ingress Nginx com Cert Manager no cluster OKE da Oracle Cloud utilizando o Helm.

## Pré-requisitos

Antes de iniciar a instalação, você deve personalizar os arquivos de configuração para o cert-manager.

1. Altere o arquivo `cert-manager/prod-issuer.yaml` e `cert-manager/stage-issuer.yaml` com o seu email.

2. Altere o arquivo `nginx/ingress.yaml` com o seu domínio.

Por padrão, estamos utilizando o stage-issuer por se tratar de um ambiente de teste. Caso queira utilizar o prod-issuer, você precisa substituir no arquivo `nginx/ingress.yaml`.

Instale o Helm: 

```bash
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```

## Instalação do Ingress Nginx com Cert Manager

1. Instale o Ingress Nginx Controller

```bash
helm upgrade --install ingress-nginx ingress-nginx \
  --repo https://kubernetes.github.io/ingress-nginx \
  --namespace ingress-nginx \
  --set controller.service.annotations."oci\.oraclecloud\.com/load-balancer-type"=nlb \
  --set controller.service.annotations."oci-network-load-balancer\.oraclecloud\.com/security-list-management-mode"=All \
  --set controller.service.type=NodePort \
  --set controller.service.nodePorts.http=30080 \
  --set controller.service.nodePorts.https=30443
```

2. Aguarde a instalação do Ingress NGINX Controller:

```bash
kubectl wait --namespace ingress-nginx \
  --for=condition=ready pod \
  --selector=app.kubernetes.io/component=controller \
  --timeout=90s
```

3. Instale o Cert Manager
```bash
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.1/cert-manager.yaml
```

4. Instalar o prod e stage Issuer

```bash
kubectl apply -f cert-manager/prod-issuer.yaml
kubectl apply -f cert-manager/stage-issuer.yaml
```

5. Aplique os manifestos para criar o ingress e a aplicação

```bash
kubectl apply -f nginx/
```

## Desinstalação

1. Para remover o Ingress Nginx, Cert Manager e os recursos criados, execute os comandos abaixo:

```bash
kubectl delete -f nginx/
kubectl delete -f cert-manager/
kubectl delete -f https://github.com/cert-manager/cert-manager/releases/download/v1.14.1/cert-manager.yaml
helm uninstall ingress-nginx -n ingress-nginx
kubectl delete secrets -n ingress-nginx ingress-nginx-admission letsencrypt-staging nginx-tls nginx-cert-h28xx
kubectl delete secret letsencrypt-staging nginx-tls
```