# Resumo da Arquitetura

## Descrição dos Recursos Criados

### VPC (Virtual Private Cloud):

  -  Uma VPC dedicada para isolar a rede do cluster EKS.
     Subnets públicas e privadas distribuídas em múltiplas zonas de disponibilidade.
     Internet Gateway para permitir acesso à internet nas subnets públicas.
     Route Tables e associações para roteamento adequado entre subnets e internet.

### Cluster EKS:

  -  Criação do cluster Amazon EKS, especificando nome, versão do Kubernetes, subnets e VPC.
     IAM Role para o cluster com a política AmazonEKSClusterPolicy.
     Tags para identificação e organização dos recursos.
    
### Add-on CNI (Amazon VPC CNI):

  - Instalação automática do add-on vpc-cni para gerenciamento de rede dos pods no EKS.
    
### Node Groups (Grupos de Nós):

  - Dois grupos de nós gerenciados (Managed Node Groups):
      Privado: Nodes em subnets privadas.
      Público: Nodes em subnets públicas.
  - IAM Role para os nodes, com as políticas:
      AmazonEKSWorkerNodePolicy
      AmazonEC2ContainerRegistryReadOnly
      AmazonEKS_CNI_Policy
    Configuração de escalonamento (min, max, desired) e tipos de instância.
    Tags para identificação dos nodes e integração com o cluster.

### Outputs:

  - IDs da VPC, subnets privadas, nome do cluster, nomes dos nodegroups privados e públicos.

## VPC
- 1 subnets públicas
- 2 subnets privadas
- Internet Gateway
- Route Tables para públicas e privadas

## EKS Cluster
- Criado nas subnets privadas e pública

### Node Groups
- **nodegroup_private:**  
  2 a 3 nodes (EC2) em subnets privadas  
  Usados para workloads internos, não expostos diretamente à internet
- **nodegroup_public:**  
  1 node (EC2) em subnet pública  
  Pode ser usado para workloads que precisam acesso direto da internet (ex: Load Balancer, NAT, etc.)

---

## Fluxo Visual

```
+-------------------+         +-------------------+
|    Internet       |         |    Internet       |
+--------+----------+         +--------+----------+
         |                             |
         |                             |
+--------v----------+         +--------v----------+
|  Public Subnets   |         |  Private Subnets  |
|  (1 node group)   |         |  (1 node group)   |
|  1x EC2 (EKS)     |         |  2x EC2 (EKS)     |
+--------+----------+         +--------+----------+
         |                             |
         |                             |
+--------v----------+         +--------v----------+
|  Internet Gateway |         |   NAT Gateway     |
+-------------------+         +-------------------+
         |
+--------v----------+
|       VPC         |
+-------------------+
```

---

## Resumo dos Módulos

- **modules/vpc:** Cria VPC, subnets públicas/privadas, rotas, IGW
- **modules/eks:** Cria o cluster EKS nas subnets privadas
- **modules/nodegroup_private:** Node group privado (2 nodes min, 3 max)
- **modules/nodegroup_public:** Node group público (1 node)

---

## Benefícios

- **Segurança:** Workloads sensíveis ficam em subnets privadas
- **Flexibilidade:** Pode expor serviços específicos via node público
- **Escalabilidade:** Node groups separados permitem escalonamento independente

---

# ✅ Estrutura recomendada para projetos Terraform modulares

```
eks-terraform/
├── main.tf
├── variables.tf
├── outputs.tf
├── provider.tf
├── versions.tf
├── terraform.tfvars
├── modules/
│   ├── vpc/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── eks/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   ├── nodegroup_private/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   └── nodegroup_public/
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
```

---

## Essa estrutura permite:

- 🔁 **Reutilização de módulos** (`modules/eks`, `modules/vpc`) em outros ambientes (ex: staging, dev, prod)
- 📦 **Separação de responsabilidades** (VPC, EKS, NodeGroups)
- 🚀 **Ambientes isolados** (usando workspaces ou subpastas: `envs/prod`, `envs/dev`)

---

# ✨ Benefícios dessa estrutura

| Vantagem      | Descrição                                         |
|---------------|---------------------------------------------------|
| 🔁 Reutilização | Pode usar `modules/` em diferentes ambientes      |
| 🔒 Segurança   | Pode isolar e versionar os módulos                |
| 🌍 Multiambiente | Fácil adaptação para dev, stage, prod           |
| 🔧 Manutenção  | Cada módulo é autocontido e fácil de atualizar    |

---

## 🧠 Explicação dos módulos

### Módulo `eks`
| Recurso           | Função                                               |
|-------------------|------------------------------------------------------|
| aws_iam_role      | Role que permite ao EKS controlar recursos           |
| aws_eks_cluster   | Cria o cluster EKS nas subnets da VPC                |
| depends_on        | Garante que o role esteja pronto antes do cluster    |

### Módulo `vpc`
| Recurso           | Função                                               |
|-------------------|------------------------------------------------------|
| aws_vpc           | Cria a VPC principal                                 |
| aws_subnet        | Cria 3 subnets privadas em zonas diferentes          |
| outputs           | Retorna o ID da VPC e os IDs das subnets             |

### Módulo `nodegroup_private` e `nodegroup_public`
| Recurso             | Função                                             |
|---------------------|----------------------------------------------------|
| aws_eks_node_group  | Cria os nós gerenciados (workers) com autoscaling  |
| aws_iam_role        | Permite ao EC2 se conectar ao EKS como worker      |
| instance_types      | Define o tipo de instância EC2 para os workers     |