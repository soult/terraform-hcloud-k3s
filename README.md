# Kubernetes (k3s) Terraform installer for Hetzner Cloud

This Terraform module creates a Kubernetes Cluster on Hetzner Cloud
infrastructure running Ubuntu 20.04. The cluster is designed to take advantage
of the Hetzner private network, and is equiped with Hetzner specific cluster
enhancements.

Cluster size and instance types are configurable through Terraform variables.

## Install

### Prerequisites

- Terraform must be installed
- Bash must be installed
- SSH should be installed and configured with an SSH Key and Agent (Recommended)
- Having `kubectl`/`jq` installed is recommended

Note that you'll need Terraform v0.12 or newer to run this project.

### Hetzner Cloud API Token

Before running the project you'll have to create an access token for Terraform
to connect to the Hetzner Cloud API.

```bash
read -sp "Hetzner Cloud API Token: " TF_VAR_hcloud_token # Enter your Hetzner Cloud API Token (it will be hidden)
export TF_VAR_hcloud_token
```

## Usage

Create a new directory and copy `examples/main.tf` there.

That's all it takes to get started!

Pin to a specific module version using `version = "..."` to avoid upgrading to a
version with breaking changes. Upgrades to this module could potentially replace
all master and worker nodes resulting in data loss. The `terraform plan` will
report this, but it may not be obvious.

Create an Hetzner Cloud Kubernetes cluster with one master and a node:

```bash
terraform apply
```

This will do the following:

- provisions Hetzner Cloud Instances with Ubuntu 20.04 (the instance type/size
  of the `master` and the `node` may be different)
- installs K3S components and supporting binaries
- joins the nodes in the cluster
  - installs Hetzner Cloud add-ons:
    - [CSI](https://github.com/hetznercloud/csi-driver) (Container Storage
      Interface driver for Hetzner Cloud Volumes)
    - [CCM](https://github.com/hetznercloud/hcloud-cloud-controller-manager)
      (Kubernetes cloud-controller-manager for Hetzner Cloud)
- creates two bash scripts to setup/destroy new context in the kubectl admin
  config file for local `kubectl`

After applying the Terraform plan you'll see several output variables like the
master public IP and nodes IPs.

```bash
terraform destroy -force
```

Be sure to clean-up any CSI created Block Storage Volumes, and CCM created
NodeBalancers that you no longer require.

## Addons Included

### [**Hetzner Cloud cloud controller manager (CCM)**](https://github.com/hetznercloud/hcloud-cloud-controller-manager)

The Hetzner Cloud cloud controller manager integrates your Kubernets cluster
with the Hetzner Cloud API. Read more about kubernetes cloud controller managers
in the
[kubernetes documentation](https://kubernetes.io/docs/tasks/administer-cluster/running-cloud-controller/).

#### Features

- **instances interface**: adds the server type to the
  `beta.kubernetes.io/instance-type` label, sets the external ipv4 and ipv6
  addresses and deletes nodes from Kubernetes that were deleted from the Hetzner
  Cloud.
- **zones interface**: makes Kubernetes aware of the failure domain of the
  server by setting the `failure-domain.beta.kubernetes.io/region` and
  `failure-domain.beta.kubernetes.io/zone` labels on the node.
- **Private Networks**: allows to use Hetzner Cloud Private Networks for your
  pods traffic.
- **Load Balancers**: allows to use Hetzner Cloud Load Balancers with Kubernetes
  Services

### [**Container Storage Interface driver for Hetzner Cloud (CSI)**](https://github.com/hetznercloud/csi-driver)

This is a Container Storage Interface driver for Hetzner Cloud enabling you to
use Volumes within Kubernetes.

When a `PV` is deleted, the Hetzner Block Storage Volume will be deleted as
well, based on the `ReclaimPolicy`.

[Learn More about Persistent Volumes on kubernetes.io.](https://kubernetes.io/docs/concepts/storage/persistent-volumes/)

## Related Projects

- [k-andy](https://github.com/StarpTech/k-andy) Zero friction Kubernetes stack
  on Hetzner Cloud
  - terraform-based stack
  - Distributed across multiple Hetzner sites and data centers
  - Support for multiple control-plane servers
- [hetzner-cloud-k3s](https://github.com/vitobotta/hetzner-cloud-k3s) A fully
  functional, super cheap Kubernetes cluster in Hetzner Cloud in 1m30s or less
  - Not terraform-based
  - Scripts that make it easy to manage a cluster
- [Rancher system-upgrade-controller](https://rancher.com/docs/k3s/latest/en/upgrades/automated/)
