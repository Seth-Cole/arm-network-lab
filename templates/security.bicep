// ============================================
// File: security.bicep
// Purpose: Template for creating netowrk security resources in Azure.
// Notes: This template will contain resources such as NSGs, firewall is a security resource but due to the complexity 
// ============================================

metadata author = 'Seth Cole'
metadata date = '01-26-2026'
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
  }
}




// ---------------------------------------------
// Modules (child components) 
// Purpose: Compose deployment by calling other .bicep files (child components)
//  Impliments parent + child design
// ---------------------------------------------


// ---------------------------------------------
// Outputs (exported values)
// Purpose: Returns useful values from this template after deployment
// ---------------------------------------------
output locationUsed string = location
output environmentUsed string = environment
output baseNameUsed string = baseName
