# Service Account

Além de utilizar o `Session Token` ou a `API Key` para autenticar no cluster, você pode utilizar um `Service Account`. Uma das vantagens do `Service Account` é a possibilidade de poder utillizar essse `token` para autenticar processos e ferramentas que acessam o cluster, como ferramentas de integração contínua e entrega contínua (CI/CD).

Neste exemplo, vamos criar um `Service Account` e um `ClusterRoleBinding` com permissões de administrador para o cluster. Em seguida, vamos criar um `token` e adicionar ao `Secret` do `Service Account`. Por fim, vamos adicionar o `Service Account` e o `token` ao arquivo `kubeconfig` para acessar o cluster.

## Criando um Service Account

1. Para iniciarmos, é necessário que o `KUBECONFIG` esteja configurado corretamente e que você tenha acesso ao cluster. Para testar, basta executar qualquer comando no cluster:

```bash
kubectl get nodes
```

2. Crie o `Service Account`:

```bash
kubectl -n kube-system create serviceaccount <service-account-name>
```

3. Crie o `ClusterRoleBinding` com permissões de administrador:

```bash
kubectl create clusterrolebinding <cluster-role-binding-name> --clusterrole=cluster-admin --serviceaccount=kube-system:<service-account-name>
```

4. Crie o arquivo `oke-kubeconfig-sa-token.yaml` para criar o `token` e adicionar ao `Secret`:

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: oke-kubeconfig-sa-token
  namespace: kube-system
  annotations:
    kubernetes.io/service-account.name: <service-account-name>
type: kubernetes.io/service-account-token
```

```bash
kubectl apply -f oke-kubeconfig-sa-token.yaml
```

5. Confirme que o `token` foi criado:

```bash
kubectl describe secrets oke-kubeconfig-sa-token -n kube-system
```

6. Agora vamos adicionar o valor do `token` a uma variável de ambiente:

```bash
TOKEN=`kubectl -n kube-system get secret oke-kubeconfig-sa-token -o jsonpath='{.data.token}' | base64 --decode`
```

7. Adicione a `Service Account` e o `token` como uma nova definição de usuário no arquivo `kubeconfig`:

```bash
kubectl config set-credentials <service-account-name> --token=$TOKEN
```

8. Vincule o `Service Account` ao usuário que acabamos de criar:

```bash
kubectl config set-context --current --user=<service-account-name>
```

9. Confirme que o `Service Account` foi adicionado ao arquivo `kubeconfig`:

```bash
kubectl config view
```

10. Agora você pode usar o `Service Account` para acessar o cluster:

```bash
kubectl get nodes
```

## Removendo o Service Account

Para remover a `Service Account` e todos os recursos associados a ela, siga os passos abaixo:

1. Remova a `Service Account` do arquivo `kubeconfig`:

```bash
kubectl config unset users.<service-account-name>
```

2. Delete a `Service Account`:

```bash
kubectl -n kube-system delete serviceaccount <service-account-name>
```

3. Delete o `ClusterRoleBinding`:

```bash
kubectl delete clusterrolebinding <cluster-role-binding-name>
```

4. Delete o `Secret`:

```bash
kubectl delete secret oke-kubeconfig-sa-token -n kube-system
```

## Referências

Para saber mais sobre `Service Account` e `RBAC` no Kubernetes, consulte esses links:

- [Documentação Oficial](https://kubernetes.io/docs/concepts/security/service-accounts/)
- [Livro "Descomplicando Kubernetes" DAY-15: Descomplicando RBAC e controle de acesso no Kubernetes](https://livro.descomplicandokubernetes.com.br/pt/day-15/)
- [Adicionando um Token de Autenticação de Conta de Serviço a um Arquivo Kubeconfig](https://docs.oracle.com/pt-br/iaas/Content/ContEng/Tasks/contengaddingserviceaccttoken.htm#Adding_a_Service_Account_Authentication_Token_to_a_Kubeconfig_File)