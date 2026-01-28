// ============================================
// File: network.bicep
// Purpose: Deploy core network components for the lab
// Scope: vnet + subnets only
// ============================================

metadata author = 'Seth Cole'
metadata date = '01-23-2026'
metadata description = 'Network Component for ARM/BICEP Lab'

//---------------------------------------------
// Target Scope 
// Purpose: defines the scope of deployment for this Bicep template 
// Scope: Network resource are being deployed at the resource group level
// ---------------------------------------------
targetScope = 'resourceGroup'

// ---------------------------------------------
// Parameters
// Purpose: 
// ---------------------------------------------
param location string = resourceGroup().location
param namePrefix string = 'az'

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
// Purpose: The actual Azure resources this template owns and deploys
// Notes: Microsoft suggest writing subnets as a child resource of the vnet, so for this case we will separate them out
// ---------------------------------------------
resource  VNET 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${baseName}-vnet'
  location: regionToken
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
  }
}

resource AzureFirewallSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: 'AzureFirewallSubnet'
  parent: VNET
  properties: {
    addressPrefix: '10.0.1.0/26'
  }
}

resource AdminSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: '${baseName}-adsn'
  parent: VNET
  properties: {
    addressPrefix: '10.0.2.0/24'
  }
}

resource WorkLoadSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: '${baseName}-wlsn'
  parent: VNET
  properties: {
    addressPrefix: '10.0.3.0/24'
  }
}

resource AzureFirewallManagementSubnet 'Microsoft.Network/virtualNetworks/subnets@2021-05-01' = {
  name: 'AzureFirewallManagementSubnet'
  parent: VNET
  properties: {
    addressPrefix: '10.0.4.0/26'
  }
}

// ---------------------------------------------
// Modules (child components) 
// Purpose: Compose deployment by calling other .bicep files (child components)
// Impliments parent + child design
// Notes: None for this template
// ---------------------------------------------


// ---------------------------------------------
// Outputs (exported values)
// Purpose: Returns useful values from this template after deployment
// ---------------------------------------------
output locationUsed string = regionToken
output environmentUsed string = environment
output baseNameUsed string = baseName
output vnetId string = VNET.id
output AzureFirewallSubnetId string = AzureFirewallSubnet.id
output AdminSubnetId string = AdminSubnet.id
output AdminSubnetName string = AdminSubnet.name
output WorkLoadSubnetId string = WorkLoadSubnet.id
output WorkloadSubnetName string = WorkLoadSubnet.name
output AzureFirewallManagementSubnetId string = AzureFirewallManagementSubnet.id
