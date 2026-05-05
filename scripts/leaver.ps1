Start-Transcript -Path "C:\Users\mani kumar\OneDrive\Desktop\IAM-JML-Automation\logs\leaver-log.txt"

$users = Import-Csv "C:\Users\mani kumar\OneDrive\Desktop\IAM-JML-Automation\data\users.csv"

$roleId = "818a7221-3168-499e-9de2-7e8daed884a8"

foreach ($user in $users) {

    if ($user.Department -ne "Leaver") {
        continue
    }

    $existingUser = Get-MgUser -UserId $user.UserPrincipalName -ErrorAction SilentlyContinue

    if (-not $existingUser) {
        Write-Host "User not found"
        continue
    }

    Write-Host "Processing LEAVER: $($user.DisplayName)"

    # Disable account
    Update-MgUser -UserId $existingUser.Id -AccountEnabled:$false
    Write-Host "Account disabled"

    # Remove groups only
    $groups = Get-MgUserMemberOf -UserId $existingUser.Id

    foreach ($g in $groups) {

        if ($g.'@odata.type' -eq "#microsoft.graph.group") {

            Remove-MgGroupMemberByRef `
                -GroupId $g.Id `
                -DirectoryObjectId $existingUser.Id

            Write-Host "Removed from group"
        }
    }

    # Remove role
    $hasRole = Get-MgDirectoryRoleMember -DirectoryRoleId $roleId | Where-Object { $_.Id -eq $existingUser.Id }

    if ($hasRole) {
        Remove-MgDirectoryRoleMemberByRef `
            -DirectoryRoleId $roleId `
            -DirectoryObjectId $existingUser.Id

        Write-Host "Role removed"
    }
}

Stop-Transcript