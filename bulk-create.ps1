$users = Import-Csv "C:\Users\mani kumar\OneDrive\Desktop\IAM-Project-Level1\data\users.csv"

foreach ($user in $users) {
    try {
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