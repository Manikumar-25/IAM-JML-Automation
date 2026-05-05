Start-Transcript -Path "C:\Users\mani kumar\OneDrive\Desktop\IAM-JML-Automation\ogs\mover-log.txt"

$users = Import-Csv "C:\Users\mani kumar\OneDrive\Desktop\IAM-JML-Automation\data\users.csv"

$roleId = "818a7221-3168-499e-9de2-7e8daed884a8"
$hrGroupId = "6ce78fc2-20f4-4477-a63b-ea3f064bb918"
$internsGroupId = "acd1cde0-f86a-4bbc-b15d-e83efd2ad70d"

foreach ($user in $users) {
    try {
        $existingUser = Get-MgUser -UserId $user.UserPrincipalName -ErrorAction SilentlyContinue

        if (-not $existingUser) {
            Write-Host "User not found: $($user.DisplayName)"
            continue
        }

        Write-Host "Processing mover: $($user.DisplayName)"

        # Get current memberships
        $groups = Get-MgUserMemberOf -UserId $existingUser.Id

        $isInHR = $groups | Where-Object { $_.Id -eq $hrGroupId }
        $isInIntern = $groups | Where-Object { $_.Id -eq $internsGroupId }

        # CASE 1: Moving to HR
        if ($user.Department -eq "HR") {

            # Remove from Intern group
            if ($isInIntern) {
                Remove-MgGroupMemberByRef `
                    -GroupId $internsGroupId `
                    -DirectoryObjectId $existingUser.Id

                Write-Host "Removed from Intern group"
            }

            # Add to HR group
            if (-not $isInHR) {
                New-MgGroupMemberByRef `
                    -GroupId $hrGroupId `
                    -BodyParameter @{
                        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($existingUser.Id)"
                    }

                Write-Host "Added to HR group"
            }

            # Assign role
            $roleMembers = Get-MgDirectoryRoleMember -DirectoryRoleId $roleId | Where-Object { $_.Id -eq $existingUser.Id }

            if (-not $roleMembers) {
                New-MgDirectoryRoleMemberByRef `
                    -DirectoryRoleId $roleId `
                    -BodyParameter @{
                        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($existingUser.Id)"
                    }

                Write-Host "User Administrator role assigned"
            }
        }

        # CASE 2: Moving to Intern
        elseif ($user.Department -eq "Intern") {

            # Remove from HR group
            if ($isInHR) {
                Remove-MgGroupMemberByRef `
                    -GroupId $hrGroupId `
                    -DirectoryObjectId $existingUser.Id

                Write-Host "Removed from HR group"
            }

            # Add to Intern group
            if (-not $isInIntern) {
                New-MgGroupMemberByRef `
                    -GroupId $internsGroupId `
                    -BodyParameter @{
                        "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($existingUser.Id)"
                    }

                Write-Host "Added to Intern group"
            }

            # Remove role
            $roleMembers = Get-MgDirectoryRoleMember -DirectoryRoleId $roleId | Where-Object { $_.Id -eq $existingUser.Id }

            if ($roleMembers) {
                Remove-MgDirectoryRoleMemberByRef `
                    -DirectoryRoleId $roleId `
                    -DirectoryObjectId $existingUser.Id

                Write-Host "User Administrator role removed"
            }
        }

    }
    catch {
        Write-Host "Error processing $($user.DisplayName)"
        Write-Host $_
    }
}

Stop-Transcript