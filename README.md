## Azure DevOps Deployment

The infrastructure is deployed using an Azure DevOps YAML pipeline. The pipeline performs Bicep validation first and deploys the infrastructure only when validation succeeds.

### Pipeline Flow

```text
Azure DevOps Repository
        |
        v
   Validate Stage
        |
        +-- Install Bicep
        |
        +-- Build Bicep
        |
        +-- Validate Azure Deployment
        |
        v
    Deploy Stage
        |
        +-- Deploy Bicep
        |
        v
   Azure Resources
        |
        +-- Virtual Network
        +-- AKS
        +-- Azure Container Registry
        +-- Log Analytics Workspace
        +-- Jumpbox
```

### Azure DevOps Configuration

The following Azure DevOps components are required:

| Component            | Value                               |
| -------------------- | ----------------------------------- |
| Azure DevOps Project | `AKS-LandingZone-Lab`               |
| Repository           | `azure-enterprise-aks-landing-zone` |
| Service Connection   | `sc-aks-lab`                        |
| Variable Group       | `AKS-LAB`                           |
| Azure Resource Group | `rg-aks-lab`                        |
| Deployment Region    | `East US`                           |

The Azure Resource Manager service connection is used by the `AzureCLI@2` tasks in the pipeline to authenticate to Azure.

### Variable Group

The pipeline references the following Azure DevOps variable group:

```yaml
variables:
- group: AKS-LAB
```

The variable group contains the deployment configuration required by the pipeline, including the target resource group.

### Pipeline YAML

The pipeline is located at:

```text
pipelines/azure-pipelines.yml
```

The pipeline is triggered when changes are pushed to the `main` branch.

```yaml
trigger:
- main
```

The pipeline contains two stages:

### Stage 1 – Validate

The Validate stage:

1. Checks out the repository.
2. Installs Azure Bicep.
3. Builds the Bicep template.
4. Validates the Azure Resource Manager deployment.

The validation command is:

```bash
az deployment group validate \
  --resource-group $(resourceGroup) \
  --template-file bicep/main.bicep \
  --parameters @parameters/dev.parameters.json
```

### Stage 2 – Deploy

The Deploy stage runs only when the Validate stage succeeds.

```yaml
dependsOn: Validate
condition: succeeded()
```

The infrastructure is deployed using:

```bash
az deployment group create \
  --resource-group $(resourceGroup) \
  --template-file bicep/main.bicep \
  --parameters @parameters/dev.parameters.json
```

## Successful Deployment

The AKS infrastructure was successfully deployed through the Azure DevOps pipeline.

### Deployed AKS Cluster

| Property           | Value                                         |
| ------------------ | --------------------------------------------- |
| AKS Cluster        | `akslabprivate`                               |
| Resource Group     | `rg-aks-lab`                                  |
| Azure Region       | `East US`                                     |
| Kubernetes Version | `1.35.7`                                      |
| Provisioning State | `Succeeded`                                   |
| AKS FQDN           | `akslabprivate-1z4klgj7.hcp.eastus.azmk8s.io` |

The AKS cluster is configured as a private AKS environment. Kubernetes API access therefore requires connectivity from an authorized network location that can resolve and reach the private AKS API endpoint.

## Deployment Validation

The successful deployment was verified using Azure CLI:

```bash
az aks list \
  --resource-group rg-aks-lab \
  --output table
```

The deployment returned:

```text
Name           Location    ResourceGroup    KubernetesVersion    CurrentKubernetesVersion    ProvisioningState
-------------  ----------  ---------------  -------------------  --------------------------  -----------------
akslabprivate  eastus      rg-aks-lab       1.35                 1.35.7                      Succeeded
```

Further validation should include:

```bash
az aks show \
  --resource-group rg-aks-lab \
  --name akslabprivate
```

and, from a network location with access to the private AKS API:

```bash
az aks get-credentials \
  --resource-group rg-aks-lab \
  --name akslabprivate
```

Then verify the Kubernetes nodes:

```bash
kubectl get nodes
```

## Cleanup

The complete lab environment can be removed by deleting the resource group:

```bash
az group delete \
  --name rg-aks-lab \
  --yes \
  --no-wait
```

> **Note:** Do not execute the cleanup command against a resource group containing production or shared resources.

**Author**
**Manzoor Nayeem**

This repository was created as a hands-on Azure Infrastructure as Code laboratory to demonstrate practical experience with Microsoft Azure, Terraform, cloud networking, compute, automation, and infrastructure deployment.

The project is focused on continuous learning and experimentation with Azure architecture, Infrastructure as Code, automation, security, and DevOps practices.

**Disclaimer**

This repository is intended for educational, laboratory, and demonstration purposes.

Configurations should be reviewed, secured, and adapted before being used in production environments.
