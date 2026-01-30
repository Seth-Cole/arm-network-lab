// ============================================
// File: bicep_template.bicep
// Purpose: Template for creating other Bicep templates
// Notes: This template serves as a starting point for all Bicep templates in this project.
// ============================================

metadata author = 'Seth Cole'
metadata date = '01-29-2026'
metadata description = 'Removing circulary dependency between network and security templates by deploying NSG association in its own template.'

//---------------------------------------------
// Target scope 
// Purpose: defines where template is deployed (can be 'resourceGroup', 'subscription', 'managementGroup', or 'tenant')
// ---------------------------------------------
targetScope = 'resourceGroup'

// ---------------------------------------------
// Parameters (inputs)
// Purpose:
// ---------------------------------------------
param location string = resourceGroup().location
param namePrefix string = 'az'

@allowed([
  'lab'
])

param environment string = 'lab'
//pulling admin subnet and nsg Ids frorm main template
param adminNSGId string
param adminSubnetId string
// pulling workload subnet and nsg Ids from main template
param workloadNSGId string
param workloadSubnetId string

// ---------------------------------------------
// Variables
// ---------------------------------------------
var baseName = '${namePrefix}-${environment}'

// ---------------------------------------------
// Resources
// Purpose: The actual Azure resources this template owns and deploys
// ---------------------------------------------
resource deployAdminNSG 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  name: '${adminSubnetId}/networkSecurityGroup'
  properties: {
    networkSecurityGroup: {
      id: adminNSGId
    }
  }
}

resource deployWorkloadNSG 'Microsoft.Network/virtualNetworks/subnets@2025-05-01' = {
  name: '${workloadSubnetId}/networkSecurityGroup'
  properties: {
    networkSecurityGroup: {
      id: workloadNSGId
    }
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
