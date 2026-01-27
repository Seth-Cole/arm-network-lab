// ============================================
// File: bicep_template.bicep
// Purpose: Template used as the parent template for all other Bicep templates in this project.
// Notes: Main will be used to call both network.bicep and security.bicep for resource deployment.
// ============================================

metadata author = 'Seth Cole'
metadata date = '01-27-2026'
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
// Purpose: Compose deployment by calling other .bicep files (child components)
//  Impliments parent + child design
// ---------------------------------------------
module networkTemplate './network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: regionToken
    namePrefix: namePrefix
    environment: environment
  }
}
// Outputs from network module
output vnetID string = networkTemplate.outputs.vnetId
output AzureFirewallSubnetID string = networkTemplate.outputs.AzureFirewallSubnetId
output AdminSubnetID string = networkTemplate.outputs.AdminSubnetId
output WorkloadSubnetID string = networkTemplate.outputs.WorkLoadSubnetId
output AzureFirewallManagementSubnetID string = networkTemplate.outputs.AzureFirewallManagementSubnetId


module securityTemplate './security.bicep' = {
  name: 'securityDeployment'
  params: {
    location: regionToken
    namePrefix: namePrefix
    environment: environment
    AzureFirewallSubnetId: networkTemplate.outputs.AzureFirewallManagementSubnetId
  }
}
// Outputs from security module
output firewallID string = securityTemplate.outputs.firewallId
output firewallPublicIpID string = securityTemplate.outputs.firewallPublicIpId
output adminNSGID string = securityTemplate.outputs.adminNSGId
output workloadNSGID string = securityTemplate.outputs.workloadNSGId


// ---------------------------------------------
// Outputs (exported values)
// Purpose: Returns useful values from this template after deployment
// ---------------------------------------------
output locationUsed string = regionToken
output environmentUsed string = environment
output baseNameUsed string = baseName
