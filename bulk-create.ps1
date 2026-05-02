Start-Transcript -Path "C:\Users\mani kumar\OneDrive\Desktop\IAM-JML-Automation\log.txt"

$users = Import-Csv "C:\Users\mani kumar\OneDrive\Desktop\IAM-JML-Automation\users.csv"

foreach ($user in $users) {
    try {
        #Validation: Check reequired fields
        if(-not $user.DisplayName -or -not $user.UserPrincipalName) {
            Write-Host "Invalid user data"
            continue
        }
       
        #checks if user already exists
        $existing = Get-MgUser -UserId $user.UserPrincipalName -ErrorAction SilentlyContinue
        
        #creates user if doesnt exist
        if (-not $existing) {

            $passwordprofile = @{
                Password = "Temp@12345" 
                ForceChangePasswordNextSignIn = $true
            }

            New-MgUser `
            -DisplayName $user.DisplayName `
            -UserPrincipalName $user.UserPrincipalName `
            -MailNickname ($user.DisplayName -replace " ", "") `
            -PasswordProfile $passwordprofile `
            -AccountEnabled

            Write-Host "Created: $($user.DisplayName)" -ForegroundColor Green

            #Dept-based logic
            if($user.Department -eq "HR") {
                Write-Host "$($user.DisplayName) assigned to HR Logic"
            }
            elseif ($user.Department -eq "Intern") {
                Write-Host "$($user.DisplayName) assigned to restricted access"
            }
        }
        else {
            Write-Host "Already exists: $($user.DisplayName)"
        }
    }
    catch {
        Write-Host "Error creating $($user.DisplayName)" -ForegroundColor Red
        Write-Host $_
    }
}

Stop-Transcript