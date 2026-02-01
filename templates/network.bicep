// ============================================
// File: network.bicep
// Purpose: Deploy core network components for the lab
// Scope: vnet + subnets only
// ============================================

metadata author = 'Seth Cole'
metadata date = '02-01-2026'
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
param adminNSGId string
param workloadNSGId string

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
// Notes: All subnets are declared inline inside the VNet properties.subnets array.
//        This ensures ARM processes them as a single write operation, avoiding
//        the AnotherOperationInProgress collision that occurs when subnets are
//        declared as separate child resources and ARM fires them in parallel.
// ---------------------------------------------
resource VNET 'Microsoft.Network/virtualNetworks@2021-05-01' = {
  name: '${baseName}-vnet'
  location: regionToken
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.1.0/26'
        }
      }
      {
        name: '${baseName}-adsn'
        properties: {
          addressPrefix: '10.0.2.0/24'
          networkSecurityGroup: {
            id: adminNSGId
          }
        }
      }
      {
        name: '${baseName}-wlsn'
        properties: {
          addressPrefix: '10.0.3.0/24'
          networkSecurityGroup: {
            id: workloadNSGId
          }
        }
      }
      {
        name: 'AzureFirewallManagementSubnet'
        properties: {
          addressPrefix: '10.0.4.0/26'
        }
      }
    ]
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
// Purpose: Returns useful values from network template after deployment
// ---------------------------------------------
output locationUsed string = regionToken
output environmentUsed string = environment
output baseNameUsed string = baseName
output vnetId string = VNET.id
output vnetName string = VNET.name
output AzureFirewallSubnetId string = '${VNET.id}/subnets/AzureFirewallSubnet'
output AdminSubnetId string = '${VNET.id}/subnets/${baseName}-adsn'
output AdminSubnetName string = '${baseName}-adsn'
output WorkLoadSubnetId string = '${VNET.id}/subnets/${baseName}-wlsn'
output WorkloadSubnetName string = '${baseName}-wlsn'
output AzureFirewallManagementSubnetId string = '${VNET.id}/subnets/AzureFirewallManagementSubnet'
output workloadSubnetAddressPrefix string = '10.0.3.0/24'
output adminSubnetAddressPrefix string = '10.0.2.0/24'
