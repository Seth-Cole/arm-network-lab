// ============================================
// File: security.bicep
// Purpose: Deploy Network Security Groups for the lab.
// Notes: NSGs deploy first so their IDs can be passed into network.bicep during subnet creation.
// ============================================

metadata author = 'Seth Cole'
metadata date = '02-01-2026'
metadata description = 'Template for creating NSG security resources in Azure'

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
// Purpose: Creating the NSGs for Admin and Workload subnets
// ---------------------------------------------

// NSG for Admin Subnet
resource adminNSG 'Microsoft.Network/networkSecurityGroups@2025-05-01' = { 
  location: regionToken
  name: '${baseName}-admin-nsg'
}

// NSG for Workload Subnet
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
output adminNSGId string = adminNSG.id
output workloadNSGId string = workloadNSG.id
