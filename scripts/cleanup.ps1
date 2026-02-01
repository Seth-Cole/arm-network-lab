# =============================================================
# Script Name: cleanup.ps1
# Author: Seth Cole
# Date Created: 01/2026
# =============================================================
#
# What Script will Do:
#   - Checks if user is logged into Azure
#   - Ensures specified Resource Group exists
#   - Confirms if user wants to proceed with cleanup
#   - Deletes Resource Group
#   - Checks for resource group deletion completion
# Assumptions:
#   - User is logged into Azure account (Connect-AzAccount)
#   - Resource group already exists
#   - User has permissions to delete the resource group
#
# =============================================================

# Defining the paramters for the script
param(
    [string]$ResourceGroupName = (Read-Host -Prompt "Enter the Resource Group Name to delete"),
    [string]$userAccount = (Get-AzContext).Subscription.Name
)

# Error Handling fail fast on any error
$ErrorActionPreference = "Stop"

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
    throw "No Resource Group found, please specify a valid Resource Group"
}
else {
    Write-Host "Resource Group found: $ResourceGroupName `nProceeding with cleanup confirmation"
}

## Confirming user wants to proceed with cleanup
$confirmRemove = (Read-Host -Prompt "To confirm you would like to delete these resources type Confirm (use uppercase C)")

if ($confirmRemove -ne "Confirm") {
	throw "Resource Group containing resources will not be deleted, terminating process"
}
else {
	Remove-AzResourceGroup -Name $ResourceGroupName -Force
    Write-Host "Resource group has been deleted, confirming deletion of resources`n"
}


## Checking for resource group deletion completion
do {
    Start-Sleep -Seconds 10
    $rgCheck = Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue
    if (-not $rgCheck) {
        Write-Host "Resource Group $ResourceGroupName successfully deleted."
    }
    else {
        Write-Host "Waiting for Resource Group $ResourceGroupName to be deleted..."
    }
} while ($rgCheck)
