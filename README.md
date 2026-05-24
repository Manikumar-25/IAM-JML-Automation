# Identity Lifecycle Automation

## Overview

This project implements an Identity and Access Management (IAM) lifecycle system using Microsoft Graph PowerShell and Microsoft Entra ID. It automates user onboarding, access updates, and offboarding based on input data.

## Scope

The system covers three lifecycle stages:

* **Joiner** – creates users and assigns access
* **Mover** – updates access when roles or departments change
* **Leaver** – disables accounts and removes access

## Design

The solution is data-driven. A CSV file represents the desired user state, and the scripts reconcile it with the current state in Entra ID.

```text id="arch01"
Input (CSV) → PowerShell Scripts → Microsoft Graph → Entra ID
```

## Structure

```text id="struct01"
scripts/
  joiner.ps1
  mover.ps1
  leaver.ps1

data/
  users.csv
```

## Execution

1. Update `data/users.csv`
2. Run the required script:

   * `joiner.ps1`
   * `mover.ps1`
   * `leaver.ps1`
3. Changes are applied to Entra ID

## Key Points

* Idempotent execution (safe to run multiple times)
* Role-based access control using groups and directory roles
* Secure offboarding through account disablement and access removal

## Technologies

* PowerShell
* Microsoft Graph API
* Microsoft Entra ID

## Author

Yata Mani Kumar
