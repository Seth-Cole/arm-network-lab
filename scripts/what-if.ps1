# =============================================================
# Script Name: what-if.ps1
# Author: Seth Cole
# Date Created: 01/2026
# =============================================================
#
# What Script will Do:
#   - Runs What-If analysis on main.bicep template
#   - Shows what resource will be created/modified
#   - Does not make any changes in Azure
# Assumptions:
#   - User is logged into Azure account (Connect-AzAccount)
#   - Resource group already exists
#   - Template and paramter files are in locations listed in parameters
#
# =============================================================

# Defining the paramters for the script
# Resource Group Name, main.bicep template file path, parameter file path
param(
    [string]$ResourceGroupName = (Get-AzResourceGroup | Select-Object -First 1).ResourceGroupName,
    [string]$TemplateFile = "$PSScriptRoot\..\templates\main.bicep",
    [string]$ParameterFile = "$PSScriptRoot\..\templates\parameters.dev.json",
    [string]$userAccount = (Get-AzContext).Subscription.Name
)

# Error Handling fail fast on any error
$ErrorActionPreference = "Stop"


## Testing if files exist in paths defined in paramters
if (Test-Path -Path $TemplateFile)
{
    Write-Host "Template File found, proceeding with parameter file check"
}
else {
    throw "Template File not found at path: $TemplateFile"
}


if (Test-Path -Path $ParameterFile)
{
 Write-Host "Parameter file found, proceeding with preflight checks" 
} 
else {
    throw "Parameter File not found at path: $ParameterFile"
}


## Ensuring user is logged into Azure
if (-not $userAccount)
{
    throw "No Azure account found, please login using Connect-AzAccount"
}
else {
    Write-Host "User logged into Azure as: $userAccount `nProceeding with Resource Group check"
}

## Ensuring Resource Group exists
if (-not $ResourceGroupName)
{
    throw "Resource Group not found, please create a Resource Group before running this script"
}
else {
    Write-Host "Resource Group found: $ResourceGroupName `nProceeding with What-If analysis"
}




## Running What-If analysis
Write-Host "`nRunning What-If analysis on template: $TemplateFile `nUsing parameter file: $ParameterFile `nIn resource group: $ResourceGroupName`n `Logged in as: $userAccount`n"

New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName `
    -TemplateFile $TemplateFile `
    -TemplateParameterFile $ParameterFile `
    -WhatIf