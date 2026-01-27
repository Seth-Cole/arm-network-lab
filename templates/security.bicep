// ============================================
// File: security.bicep
// Purpose: Template for creating netowrk security resources in Azure.
// Notes: This template will contain resources such as NSGs and Azure Firewall
// ============================================

metadata author = 'Seth Cole'
metadata date = '01-27-2026'
metadata description = 'Template for creating netowrk security resources in Azure'

//---------------------------------------------
// Target scope 
// Purpose: Security resources are being deployed at the resource group level
// ---------------------------------------------
targetScope = 'resourceGroup'

// ---------------------------------------------
// Parameters
// Purpose:
// ---------------------------------------------
param location string = resourceGroup().location
param namePrefix string = 'az'
param AzureFirewallSubnetId string

@allowed([
  'lab'
])

param environment string = 'lab'

// ---------------------------------------------
// Variables
// Purpose: Variables to help with naming conventions and other reusable values
// ---------------------------------------------
var regionToken = toLower(location)
var baseName = '${namePrefix}-${environment}'

// ---------------------------------------------
// Resources
// Purpose: Creating the Firewall Public IP, aswell as the Firewall and NSGs
// ---------------------------------------------


// Creating the Public IP for the Firewall first
resource firewallPublicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${baseName}-fw-pip'
  location: regionToken
  properties: {
    publicIPAddressVersion: 'IPv4'
    publicIPAllocationMethod: 'Static'
  }
    sku: {
    name: 'Standard'
    tier: 'Regional'
  }
}

// Creating the Firewall and NSGs
resource firewall 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: '${baseName}-fw'
  location: regionToken
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Basic'
    }
    ipConfigurations: [
      { 
        name: 'ipconfig' // attaching the public IP and subnet to the firewall
        properties: {
          publicIPAddress: {
            id: firewallPublicIp.id 
          }
        subnet: {
          id: AzureFirewallSubnetId
        }
       }
      }
    ]
  }
}

// Network Security Group for Admin Subnet
resource adminNSG 'Microsoft.Network/networkSecurityGroups@2025-05-01' = { 
  location: regionToken
  name: '${baseName}-admin-nsg'
}
// Network Security Group for Workload Subnet
resource workloadNSG 'Microsoft.Network/networkSecurityGroups@2025-05-01' = { 
  location: regionToken
  name: '${baseName}-workload-nsg'
}

// ---------------------------------------------
// Modules (child components) 
// Purpose: Impliments parent + child design
// ---------------------------------------------


// ---------------------------------------------
// Outputs (exported values)
// Purpose: Returns useful values from this template after deployment
// ---------------------------------------------
output locationUsed string = regionToken
output environmentUsed string = environment
output baseNameUsed string = baseName
output firewallId string = firewall.id
output firewallPublicIpId string = firewallPublicIp.id
output adminNSGId string = adminNSG.id
output workloadNSGId string = workloadNSG.id
