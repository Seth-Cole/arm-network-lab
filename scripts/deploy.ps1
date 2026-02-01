# =============================================================
# Script Name: deploy.ps1
# Author: Seth Cole
# Date Created: 01/2026
# =============================================================
#
# What Script will Do:
#   - Checks for user login to Azure
#   - Prompts user for RG name
#   - Checks for existence of main.bicep and parameter files
#   - Checks for existence of RG
#   - Confirms deployment with user
#   - Deploys main.bicep template to specified Resource Group
#   - Checks deployment status and outputs results
# Assumptions:
#   - User is logged into Azure account (Connect-AzAccount)
#   - User has permissions to create resource group
#   - User has permissions to deploy resources to the resource group
#   - Template and paramter files exist
#   - Location for deployment is set in parameters
#
# =============================================================

# Defining the paramters for the script
param(
    [string]$userAccount = (Get-AzContext).Subscription.Name,
    [string]$location = "WestUS2",
    [string]$TemplateFile = "$PSScriptRoot\..\templates\main.bicep",
    [string]$ParameterFile = "$PSScriptRoot\..\templates\parameters.dev.json"
)

# Error Handling fail fast on any error
$ErrorActionPreference = "Stop"

# Ensuring user is logged into Azure
if (-not $userAccount)
{
    throw "No Azure account found, please login using Connect-AzAccount"
}
else {
    Write-Host "User logged into Azure as: $userAccount `nProceeding with preflight checks"
}

# Check for template files
if (Test-Path -Path $TemplateFile)
{
    Write-Host "Template File found, proceeding with parameter file check"
}
else {
    throw "Template File not found at path: $TemplateFile"
}

# Check for parameter files
if (Test-Path -Path $ParameterFile)
{
    Write-Host "Parameter file found, proceeding with deployment confirmation"
}
else {
    throw "Parameter File not found at path: $ParameterFile"
}

# Prompts user for RG name
$ResourceGroupName = (Read-Host -Prompt "Enter the Resource Group Name to be used for deployment")
$userConfirmation = (Read-Host "Deploying to Resource Group $ResourceGroupName would you like to continue? (Type Yes with capital Y to proceed)")

if ($userConfirmation -ne "Yes") {
    throw "Resources and Resource Group will not be deployed, terminating process"
}

# Checks for existence of RG, creates if it does not exist
$rgCheck = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
if (-not $rgCheck)
{
    New-AzResourceGroup -Name $ResourceGroupName -Location $location
    Write-Host "Proceeding with deployment of resources to Resource Group: $ResourceGroupName"
}
else {
    Write-Host "Resource Group $ResourceGroupName found, proceeding with deployment of resources"
}

# Deploying main.bicep template to specified Resource Group
Write-Host "Starting deployment to Resource Group: $ResourceGroupName"
Write-Host "This may take several minutes, please wait..."
New-AzResourceGroupDeployment -ResourceGroupName $ResourceGroupName -TemplateFile $TemplateFile -TemplateParameterFile $ParameterFile
