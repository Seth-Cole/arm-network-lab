// ============================================
// File: firewall.bicep
// Purpose: Deploy Azure Firewall and its public IP for the lab.
// Notes: Firewall deploys last — it requires the firewall subnet ID from network.bicep.
//        Basic SKU requires both ipConfigurations and managementIpConfiguration.
// ============================================

metadata author = 'Seth Cole'
metadata date = '02-01-2026'
metadata description = 'Template for creating Azure Firewall resources in Azure'

//---------------------------------------------
// Target scope 
// Purpose: Firewall resources are being deployed at the resource group level
// ---------------------------------------------
targetScope = 'resourceGroup'

// ---------------------------------------------
// Parameters
// Purpose:
// ---------------------------------------------
param location string = resourceGroup().location
param namePrefix string = 'az'
param AzureFirewallSubnetId string
param AzureFirewallManagementSubnetId string

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
// Purpose: Creating the Firewall Public IPs and the Firewall
// ---------------------------------------------

// Public IP for the Firewall data plane
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

// Public IP for the Firewall management plane (required by Basic SKU)
resource firewallManagementPublicIp 'Microsoft.Network/publicIPAddresses@2021-05-01' = {
  name: '${baseName}-fw-mgmt-pip'
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

// Azure Firewall — Basic SKU requires both ipConfigurations and managementIpConfiguration
resource firewall 'Microsoft.Network/azureFirewalls@2021-05-01' = {
  name: '${baseName}-fw'
  location: regionToken
  properties: {
    sku: {
      name: 'AZFW_VNet'
      tier: 'Basic'
    }
    // Data plane interface — all customer traffic flows through here
    ipConfigurations: [
      { 
        name: 'ipconfig'
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
    // Management plane interface — required by Basic SKU for operational traffic
    managementIpConfiguration: {
      name: 'mgmtIpConfig'
      properties: {
        publicIPAddress: {
          id: firewallManagementPublicIp.id
        }
        subnet: {
          id: AzureFirewallManagementSubnetId
        }
      }
    }
  }
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
output firewallManagementPublicIpId string = firewallManagementPublicIp.id
