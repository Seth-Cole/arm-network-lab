// ============================================
// File: bicep_template.bicep
// Purpose: Template for creating other Bicep templates
// Notes: This template serves as a starting point for all Bicep templates in this project.
// ============================================

metadata author = 'Seth Cole'
metadata date = '01-22-2026'
metadata description = 'Bicep template to use for creating other Bicep templates for this project.'

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
var baseName = '${namePrefix}-${environment}-${regionToken}'

// ---------------------------------------------
// Resources
// Purpose: The actual Azure resources this template owns and deploys
// ---------------------------------------------
resource <symbol> '<resourceType>@<apiVersion>' = {
  name: '<resourceName>'
  location: location
  tags: tags
  properties: {
    // Resource-specific properties go here
  }
}

// ---------------------------------------------
// Modules (child components) 
// Purpose: Compose deployment by calling other .bicep files (child components)
//  Impliments parent + child design
// ---------------------------------------------
module networkModule 'network.bicep' = {
  name: 'networkDeployment'
  params: {
    location: location
    namePrefix: namePrefix
    environment: environment
  }
}

module securityModule 'security.bicep' = {
  name: 'securityDeployment'
  params: {
    location: location
    namePrefix: namePrefix
    environment: environment
  }
}

// ---------------------------------------------
// Outputs (exported values)
// Purpose: Returns useful values from this template after deployment
// ---------------------------------------------
output locationUsed string = location
output environmentUsed string = environment
output baseNameUsed string = baseName
