Start-Transcript -Path "C:\Users\mani kumar\OneDrive\Desktop\IAM-JML-Automation\logs\log.txt"

$users = Import-Csv "C:\Users\mani kumar\OneDrive\Desktop\IAM-JML-Automation\data\users.csv"

$roleId = "818a7221-3168-499e-9de2-7e8daed884a8"
$hrGroupId = "6ce78fc2-20f4-4477-a63b-ea3f064bb918"
$internsGroupId = "acd1cde0-f86a-4bbc-b15d-e83efd2ad70d"

foreach ($user in $users) {
    try {
        # Validation
        if (-not $user.DisplayName -or -not $user.UserPrincipalName) {
            Write-Host "Invalid user data"
            continue
        }

        # Get or create user
        $newUser = Get-MgUser -UserId $user.UserPrincipalName -ErrorAction SilentlyContinue

        if (-not $newUser) {
            $passwordprofile = @{
                Password = "Temp@12345"
                ForceChangePasswordNextSignIn = $true
            }

            $newUser = New-MgUser `
                -DisplayName $user.DisplayName `
                -UserPrincipalName $user.UserPrincipalName `
                -MailNickname ($user.DisplayName -replace " ", "") `
                -PasswordProfile $passwordprofile `
                -AccountEnabled

            Write-Host "Created: $($user.DisplayName)" -ForegroundColor Green
        }
        else {
            Write-Host "$($user.DisplayName) already exists"
        }

        # Common body
        $body = @{
            "@odata.id" = "https://graph.microsoft.com/v1.0/directoryObjects/$($newUser.Id)"
        }

        # HR LOGIC
        if ($user.Department -eq "HR") {

            # GROUP CHECK
            $memberCheck = Get-MgGroupMember -GroupId $hrGroupId | Where-Object { $_.Id -eq $newUser.Id }

            if (-not $memberCheck) {
                New-MgGroupMemberByRef -GroupId $hrGroupId -BodyParameter $body
                Write-Host "Added to HR group"
            }
            else {
                Write-Host "Already in HR group"
            }

            # ROLE CHECK
            $roleMembers = Get-MgDirectoryRoleMember -DirectoryRoleId $roleId | Where-Object { $_.Id -eq $newUser.Id }

            if (-not $roleMembers) {
                New-MgDirectoryRoleMemberByRef -DirectoryRoleId $roleId -BodyParameter $body
                Write-Host "User Administrator role assigned"
            }
            else {
                Write-Host "Role already assigned"
            }
        }

        # INTERN LOGIC
        elseif ($user.Department -eq "Intern") {

            $memberCheck = Get-MgGroupMember -GroupId $internsGroupId | Where-Object { $_.Id -eq $newUser.Id }

            if (-not $memberCheck) {
                New-MgGroupMemberByRef -GroupId $internsGroupId -BodyParameter $body
                Write-Host "Added to Intern group"
            }
            else {
                Write-Host "Already in Intern group"
            }
        }

    }
    catch {
        Write-Host "Error for $($user.DisplayName)" -ForegroundColor Red
        Write-Host $_
    }
}

Stop-Transcript