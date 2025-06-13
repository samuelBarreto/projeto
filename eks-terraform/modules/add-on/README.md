# Módulo `add-on` para EKS

Este módulo foi criado para facilitar a instalação e o gerenciamento de add-ons no Amazon EKS via Terraform.

## O que são add-ons?

Add-ons são componentes essenciais ou opcionais que estendem as funcionalidades do cluster EKS, como rede, DNS e proxy. Exemplos comuns:
- **vpc-cni**: Integração de rede entre pods e a VPC da AWS.
- **kube-proxy**: Gerencia o roteamento de rede e regras de iptables para serviços Kubernetes.
- **coredns**: Provedor de DNS interno do cluster.

## Como funciona o módulo

O módulo `add-on` é genérico e permite instalar qualquer add-on suportado pelo EKS, bastando informar:
- O nome do add-on (`addon_name`)
- O nome do cluster (`cluster_name`)
- (Opcional) Versão do add-on, tags, role, etc.

Exemplo de uso no `main.tf`:

```hcl
module "addon_kube_proxy" {
  source                      = "./modules/add-on"
  cluster_name                = module.eks.cluster_name
  addon_name                  = "kube-proxy"
  addon_version               = null
  resolve_conflicts_on_create = "NONE"
  resolve_conflicts_on_update = "OVERWRITE"
  tags = {
    Environment = var.environment
    ClusterName = var.cluster_name
  }
}
```

## Vantagens

- **Reutilizável:** Instale qualquer add-on apenas mudando parâmetros.
- **Padronizado:** Facilita upgrades e manutenção dos componentes essenciais do cluster.
- **Automatizado:** Gerencia dependências e tags de forma centralizada.

### Módulo `add-on` 

| Recurso             | Função                                                        |
|---------------------|---------------------------------------------------------------|
| aws_eks_addon       | Instala e gerencia add-ons oficiais do EKS (ex: vpc-cni, coredns, kube-proxy) |
| cluster_name        | Nome do cluster EKS onde o add-on será instalado              |
| addon_name          | Nome do add-on a ser instalado (ex: vpc-cni, kube-proxy)      |
| addon_version       | Versão do add-on (opcional, usa a recomendada se null)        |
| tags                | Tags aplicadas ao recurso do add-on                           |

> **Obs:** Este módulo não cria node groups nem roles, ele é focado apenas na instalação de add-ons do EKS.
