Reuses a previously designed Azure network and expresses it as Bicep templates

## How to Run
- What-If: `./scripts/whatif.ps1`
- Deploy: `./scripts/deploy.ps1`
- Cleanup: `./scripts/cleanup.ps1`

## Notes
This repo focuses on infrastructure provisioning (ARM/Bicep). Post-provisioning configuration is intentionally out of scope i.e configuring firewall rules, NSG rules, DNS records, etc.
This project soley focuses on deploying the core resources without configuration
