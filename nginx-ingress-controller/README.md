# --- ATENÇÃO --- 
### Toda configuração aqui é para laboratório. Use somente em seu ambiente de testes.
----------------------
## Configurando o nginx ingress no oke-free

-  Os manifestos usados para configurar o nginx, foram retirados do [repositorio oficial](https://github.com/nginxinc/kubernetes-ingress.git --branch v3.4.2)
git clone https://github.com/nginxinc/kubernetes-ingress.git --branch v3.4.2  


- Recomendo fortemente a leitura da [documentação oficial](https://docs.nginx.com/nginx-ingress-controller/installation/installing-nic/installation-with-manifests/).



### Configurar o controle de acesso baseado em função (RBAC)

#### Crie um namespace e uma conta de serviço:
```
kubectl apply -f deployments/common/ns-and-sa.yaml
```

#### Crie a  cluster role e uma binding para a conta de serviço:
```
kubectl apply -f deployments/rbac/rbac.yaml
```

#### Crie um ConfigMap para personalizar suas configurações do NGINX:
```
kubectl apply -f deployments/common/nginx-config.yaml
```

#### Crie um recurso IngressClass. O NGINX Ingress Controller não será iniciado sem um recurso IngressClass.
```
kubectl apply -f deployments/common/ingress-class.yaml
```

#### Crie CRDs para VirtualServer e VirtualServerRoute , TransportServer , Policy e GlobalConfiguration :
```
kubectl apply -f config/crd/bases/k8s.nginx.org_virtualservers.yaml
kubectl apply -f config/crd/bases/k8s.nginx.org_virtualserverroutes.yaml
kubectl apply -f config/crd/bases/k8s.nginx.org_transportservers.yaml
kubectl apply -f config/crd/bases/k8s.nginx.org_policies.yaml
kubectl apply -f config/crd/bases/k8s.nginx.org_globalconfigurations.yaml

```

#### Usando um DaemonSet
```
kubectl apply -f deployments/daemon-set/nginx-ingress.yaml
```


## Como acessar o NGINX Ingress Controller

#### Crie um serviço LoadBalancer

use o manifesto deployments/service/loadbalancer.yaml para criar um novo manifesto alterado: 
alterar:  type: NodePort
Adicionar: nodePort: 30080
```
  externalTrafficPolicy: Local
  type: NodePort
  ports:
  - port: 80
    targetPort: 80
    protocol: TCP
    name: http
    nodePort: 30080
```

```
kubectl apply -f deployments/service/loadbalancer-oci-free.yaml
```


#### Faça o deploy da aplicação e do ingress

no arquivo [ingress-dominio-apache-nginx](./manifestos/ingress-dominio-apache-nginx) , em host, coloque o IP do seu loadbalancer
```
kubectl apply -f ./manifestos/deployments-nginx-apache.yaml
kubectl apply -f ./manifestos/ingress-dominio-apache-nginx
```


- Todos os [manifestos](./manifestos) acima estão na pasta manifestos e caso queira, pode usa-los


```
kubectl apply -f ./manifestos/ns-and-sa.yaml
kubectl apply -f ./manifestos
```

* Para excluir:
```
kubectl delete -f ./manifestos
```

ou 


```
kubectl delete -f ./manifestos/rbac.yaml
kubectl delete -f ./manifestos/nginx-config.yaml
kubectl delete -f ./manifestos/loadbalancer-oci-free.yaml
kubectl delete -f ./manifestos/ingress-class.yaml
kubectl delete -f ./manifestos/k8s.nginx.org_virtualservers.yaml
kubectl delete -f ./manifestos/k8s.nginx.org_virtualserverroutes.yaml
kubectl delete -f ./manifestos/k8s.nginx.org_transportservers.yaml
kubectl delete -f ./manifestos/k8s.nginx.org_policies.yaml
kubectl delete -f ./manifestos/k8s.nginx.org_globalconfigurations.yaml
kubectl delete -f ./manifestos/nginx-ingress.yaml
kubectl delete -f ./manifestos/deployments-nginx-apache.yaml
kubectl delete -f ./manifestos/ingress-dominio-apache-nginx.yaml
kubectl delete -f ./manifestos/ns-and-sa.yaml
```