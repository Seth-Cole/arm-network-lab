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
#   - Template and paramter files are in standard locations
#
# =============================================================

# Defining the paramters for the script
# Resource Group Name, main.bicep template file path, parameter file path
param(
    [string]$ResourceGroupName = 'az-lab-rg',
    [string]$TemplateFile = "$PSScriptRoot\..\templates\main.bicep",
    [string]$ParameterFile = "$PSScriptRoot\..\templates\parameters.dev.json"
)

# Error Handling fail fast on any error
$ErrorActionPreference = "Stop"


write-Host "RG: $ResourceGroupName"
write-Host "Template: $templateFile"
write-Host "Parameter File: $parameterFile"