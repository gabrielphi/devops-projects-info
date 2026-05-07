# Kubernetes — Guia de Instalação

Guia de instalação e configuração do stack completo: **Traefik + cert-manager + ArgoCD**.

## Pré-requisitos

- Cluster AKS em execução e `kubectl` configurado
- `helm` v3+ instalado
- Domínio `artificerhouse.com.br` com acesso ao painel DNS

---

## Estrutura de pastas

```
kubernetes/
├── base/                        # App principal (namespace: default)
│   ├── deployment.yaml
│   ├── service.yaml
│   └── ingress.yaml
├── argocd/                      # Ingress do ArgoCD (namespace: argocd)
│   ├── ingress.yaml
│   └── kustomization.yaml
├── cert-manager/
│   ├── base/
│   │   └── clusterissuer.yaml   # ClusterIssuers staging + production
│   └── overlays/dev/
├── overlays/
│   └── dev/                     # Overlay de desenvolvimento
├── values.yml                   # Helm values — Traefik
└── argocd-values.yml            # Helm values — ArgoCD
```

---

## 1. Traefik

### Instalar via Helm

```bash
helm repo add traefik https://traefik.github.io/charts
helm repo update

helm install traefik traefik/traefik \
  --namespace traefik \
  --create-namespace \
  --values kubernetes/values.yml
```

### Obter o IP público

Após a instalação, o Azure provisiona automaticamente um Load Balancer. Aguarde o IP aparecer:

```bash
kubectl get svc -n traefik traefik -w
```

Anote o `EXTERNAL-IP` — ele será usado nos registros DNS.

---

## 2. DNS — Registros necessários

Com o IP do Traefik em mãos, crie os seguintes registros no seu provedor DNS para o domínio `artificerhouse.com.br`:

| Tipo | Nome        | Valor             | TTL |
|------|-------------|-------------------|-----|
| `A`  | `testek8s`  | `<IP do Traefik>` | 300 |
| `A`  | `argocd`    | `<IP do Traefik>` | 300 |

> **Dica:** um registro wildcard `* → <IP do Traefik>` cobre todos os subdomínios atuais e futuros.

Verifique a propagação antes de continuar:

```bash
nslookup testek8s.artificerhouse.com.br
nslookup argocd.artificerhouse.com.br
```

---

## 3. cert-manager

### Instalar via Helm

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update

helm install cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set crds.enabled=true
```

Aguarde todos os pods ficarem prontos:

```bash
kubectl get pods -n cert-manager -w
```

### Aplicar os ClusterIssuers

```bash
kubectl apply -k kubernetes/cert-manager/overlays/dev
```

Verifique se os issuers foram registrados corretamente:

```bash
kubectl get clusterissuer
```

Saída esperada:
```
NAME                     READY   AGE
letsencrypt-production   True    30s
letsencrypt-staging      True    30s
```

> Use `letsencrypt-staging` para testes — ele não tem rate limit. Troque para `letsencrypt-production` apenas quando tudo estiver funcionando.

---

## 4. ArgoCD

### Instalar via Helm

```bash
helm repo add argo https://argoproj.github.io/argo-helm
helm repo update

helm install argocd argo/argo-cd \
  --namespace argocd \
  --create-namespace \
  --values kubernetes/argocd-values.yml
```

> O `argocd-values.yml` configura `server.insecure: true`, necessário para que o Traefik termine o TLS sem conflito com o TLS interno do ArgoCD.

Aguarde os pods:

```bash
kubectl get pods -n argocd -w
```

### Aplicar o Ingress

```bash
kubectl apply -k kubernetes/argocd
```

### Obter a senha inicial

```bash
kubectl get secret argocd-initial-admin-secret \
  -n argocd \
  -o jsonpath="{.data.password}" | base64 -d
```

Acesse: **https://argocd.artificerhouse.com.br**
Login: `admin` / `<senha acima>`

> Troque a senha pelo painel após o primeiro acesso.

---

## 5. Aplicação de teste

```bash
kubectl apply -k kubernetes/overlays/dev
```

Acesse: **https://testek8s.artificerhouse.com.br**

---

## Verificar certificados TLS

```bash
# Listar todos os certificados
kubectl get certificate -A

# Detalhes de um certificado específico
kubectl describe certificate funcionou-tls -n default
kubectl describe certificate argocd-tls -n argocd
```

Se o certificado ficar em `False` por mais de 5 minutos, verifique os eventos:

```bash
kubectl describe certificaterequest -n default
kubectl logs -n cert-manager deploy/cert-manager
```

---

## Ordem de instalação resumida

```
1. Traefik       → helm install
2. DNS           → adicionar registros A
3. cert-manager  → helm install + kubectl apply -k
4. ArgoCD        → helm install + kubectl apply -k
5. App           → kubectl apply -k kubernetes/overlays/dev
```
