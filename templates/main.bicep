// ============================================
// File: main.bicep
// Purpose: Orchestrator template — calls security, network, and firewall modules.
// Notes: Deployment order: security (NSGs) → network (subnets with NSGs) → firewall.
// ============================================

metadata author = 'Seth Cole'
metadata date = '02-01-2026'
metadata description = 'Template used as the parent template for all other Bicep templates in this project.'

//---------------------------------------------
// Target scope 
// Purpose: defines where template is deployed (can be 'resourceGroup', 'subscription', 'managementGroup', or 'tenant')
// ---------------------------------------------
targetScope = 'resourceGroup'

// ---------------------------------------------
// Parameters (inputs)
// Purpose: reusable inputs for all Bicep templates, code that can be used for any Bicep template in this project
// ---------------------------------------------
param location string = resourceGroup().location
param namePrefix string = 'az'

@allowed([
  'lab'
])

param environment string = 'lab'

// ---------------------------------------------
// Variables / naming helpers
// Purpose: Variables to help with naming conventions and other reusable values
// ---------------------------------------------
var regionToken = toLower(location)
var baseName = '${namePrefix}-${environment}'

// ---------------------------------------------
// Resources
// Purpose: The actual Azure resources this template owns and deploys
// ---------------------------------------------


// ---------------------------------------------
// Modules (child components) 
// Purpose: Impliments parent + child design
// ---------------------------------------------

// 1. Security deploys first — NSGs have no dependencies
module securityTemplate './security.bicep' = {
  name: 'securityDeployment'
  params: {
    location: regionToken
    namePrefix: namePrefix
    environment: environment
  }
}

// 2. Network deploys second — receives NSG IDs so subnets are created with NSGs already attached
module networkTemplate './network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: regionToken
    namePrefix: namePrefix
    environment: environment
    adminNSGId: securityTemplate.outputs.adminNSGId
    workloadNSGId: securityTemplate.outputs.workloadNSGId
  }
}

// 3. Firewall deploys last — receives subnet IDs from network
module firewallTemplate './firewall.bicep' = {
  name: 'firewallDeployment'
  params: {
    location: regionToken
    namePrefix: namePrefix
    environment: environment
    AzureFirewallSubnetId: networkTemplate.outputs.AzureFirewallSubnetId
    AzureFirewallManagementSubnetId: networkTemplate.outputs.AzureFirewallManagementSubnetId
  }
}

// Outputs from network module
output vnetID string = networkTemplate.outputs.vnetId
output AzureFirewallSubnetID string = networkTemplate.outputs.AzureFirewallSubnetId
output AdminSubnetID string = networkTemplate.outputs.AdminSubnetId
output WorkloadSubnetID string = networkTemplate.outputs.WorkLoadSubnetId
output AzureFirewallManagementSubnetID string = networkTemplate.outputs.AzureFirewallManagementSubnetId
output vnetName string = networkTemplate.outputs.vnetName
output AdminSubnetName string = networkTemplate.outputs.AdminSubnetName
output WorkloadSubnetName string = networkTemplate.outputs.WorkloadSubnetName
output workloadSubnetAddressPrefix string = networkTemplate.outputs.workloadSubnetAddressPrefix
output adminSubnetAddressPrefix string = networkTemplate.outputs.adminSubnetAddressPrefix

// Outputs from security module
output adminNSGID string = securityTemplate.outputs.adminNSGId
output workloadNSGID string = securityTemplate.outputs.workloadNSGId

// Outputs from firewall module
output firewallID string = firewallTemplate.outputs.firewallId
output firewallPublicIpID string = firewallTemplate.outputs.firewallPublicIpId
output firewallManagementPublicIpID string = firewallTemplate.outputs.firewallManagementPublicIpId



// ---------------------------------------------
// Outputs (exported values)
// Purpose: Returns useful values from this template after deployment
// ---------------------------------------------
output locationUsed string = regionToken
output environmentUsed string = environment
output baseNameUsed string = baseName
