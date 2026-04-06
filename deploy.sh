#!/bin/bash

RG="MultiTierRG"
LOCATION="canadacentral"
VNET="MultiTierVNet"

echo "Creating Resource Group..."
az group create --name $RG --location $LOCATION

echo "Creating VNet and Subnets..."
az network vnet create \
  --resource-group $RG \
  --name $VNET \
  --address-prefix 10.0.0.0/16 \
  --subnet-name WebSubnet \
  --subnet-prefix 10.0.1.0/24

az network vnet subnet create --resource-group $RG --vnet-name $VNET --name AppSubnet --address-prefix 10.0.2.0/24
az network vnet subnet create --resource-group $RG --vnet-name $VNET --name DBSubnet --address-prefix 10.0.3.0/24

echo "Creating NSGs..."
az network nsg create --resource-group $RG --name WebNSG
az network nsg create --resource-group $RG --name AppNSG
az network nsg create --resource-group $RG --name DBNSG

echo "Configuring NSG Rules..."
az network nsg rule create --resource-group $RG --nsg-name WebNSG --name AllowSSH --priority 1000 --access Allow --protocol Tcp --direction Inbound --destination-port-range 22 --source-address-prefix '*'

az network nsg rule create --resource-group $RG --nsg-name AppNSG --name AllowWeb --priority 1000 --access Allow --protocol Tcp --direction Inbound --source-address-prefix 10.0.1.0/24 --destination-port-range '*'

az network nsg rule create --resource-group $RG --nsg-name DBNSG --name AllowApp --priority 1000 --access Allow --protocol Tcp --direction Inbound --source-address-prefix 10.0.2.0/24 --destination-port-range '*'

echo "Associating NSGs..."
az network vnet subnet update --vnet-name $VNET --name WebSubnet --resource-group $RG --network-security-group WebNSG
az network vnet subnet update --vnet-name $VNET --name AppSubnet --resource-group $RG --network-security-group AppNSG
az network vnet subnet update --vnet-name $VNET --name DBSubnet --resource-group $RG --network-security-group DBNSG

echo "Creating VMs..."

az vm create \
  --resource-group $RG \
  --location $LOCATION \
  --name WebVM \
  --image Ubuntu2204 \
  --vnet-name $VNET \
  --subnet WebSubnet \
  --size Standard_D2s_v3 \
  --admin-username azureuser \
  --generate-ssh-keys

az vm create \
  --resource-group $RG \
  --location $LOCATION \
  --name AppVM \
  --image Ubuntu2204 \
  --vnet-name $VNET \
  --subnet AppSubnet \
  --size Standard_D2s_v3 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-address ""

az vm create \
  --resource-group $RG \
  --location $LOCATION \
  --name DBVM \
  --image Ubuntu2204 \
  --vnet-name $VNET \
  --subnet DBSubnet \
  --size Standard_D2s_v3 \
  --admin-username azureuser \
  --generate-ssh-keys \
  --public-ip-address ""

echo "Deployment Complete!"