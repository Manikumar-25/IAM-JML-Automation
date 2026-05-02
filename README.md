# User Lifecycle Automation (Level 1)

## Overview

This project demonstrates automated user provisioning in Microsoft Entra ID using PowerShell and CSV input.

## Objective

To simulate a Joiner process by creating users in bulk from a structured data source.

## Tools Used

* Microsoft Entra ID
* Microsoft Graph PowerShell
* Azure CLI
* PowerShell scripting

## Workflow

1. User data is stored in a CSV file
2. PowerShell script reads the CSV
3. Script checks if user already exists
4. If not, user is created in Entra ID
5. Errors are handled gracefully

## Features Implemented

* Bulk user creation
* Duplicate user validation
* Basic error handling

## Sample Input

CSV file containing user details (DisplayName, UserPrincipalName, Department)

## Outcome

Successfully automated user onboarding process, reducing manual effort and ensuring consistency.

## Future Improvements

* Add role-based access control
* Implement logging
* Extend to full JML lifecycle

## Level 2 Enhancements

* Implemented input validation for user attributes
* Added logging mechanism using PowerShell transcript
* Introduced department-based conditional logic for access control
* Improved error handling for reliable execution

