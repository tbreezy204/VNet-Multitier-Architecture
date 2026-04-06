# VNet-Multitier-Architecture
Deploying a VNet-Based Multi-Tier Architecture and Enforcing Access, Using NSG rules

Project Overview

This project demonstrates a multi-tier network architecture deployed on Microsoft Azure using Virtual Networks (VNets), Subnets, Network Security Groups (NSGs), and Virtual Machines (VMs). It implements a secure environment where each tier is isolated and communication is controlled via NSG rules.

The architecture consists of three tiers:

Web Tier – Public-facing VMs in WebSubnet
Application Tier – Internal VMs in AppSubnet
Database Tier – Internal VMs in DBSubnet

NSGs enforce communication rules:

Web → App: Allowed
App → DB: Allowed
DB → Web: Blocked
Architecture Diagram
         [Internet]
             |
        Public IP / SSH
             |
          WebSubnet
         [WebVM]
             |
             v
        AppSubnet
         [AppVM]
             |
             v
        DBSubnet
         [DBVM]
Features
Resource Group scoped deployment
Azure Virtual Network with multiple subnets
Network Security Groups with custom rules
VMs without public IPs (except WebVM)
SSH access to WebVM, internal communication between tiers

--------Prerequisites----------
Azure CLI
 installed
An active Azure subscription
SSH client (for Linux/Mac)

RG="MultiTierRG"
LOCATION="canadacentral"
VNET="MultiTierVNet"

--------Run deployment script---------
./deploy.sh

This will create:

Resource group
VNet and subnets
NSGs and rules
Web, App, and DB VMs
Accessing VMs
WebVM: SSH using public IP

ssh azureuser@<WebVM_PublicIP>
AppVM & DBVM: Access via WebVM or Bastion host

ssh azureuser@<PrivateIP>   # from WebVM
Testing Connectivity

From WebVM:

ping <AppVM_PrivateIP>     # Should work
ping <DBVM_PrivateIP>      # Should fail (blocked)

From AppVM:

ping <DBVM_PrivateIP>      # Should work

Project Scripts
deploy.sh – Bash script for creating all resources in Azure

NSGs enforce traffic flow between tiers
DBVM and AppVM have no public IPs
SSH access limited to WebVM or Bastion host

Author
Orji Tochukwu – Cloud Engineer | Project Owner