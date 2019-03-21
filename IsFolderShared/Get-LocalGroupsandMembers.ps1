
 Function Get-LocalGroupsandMembers { 
    
    [cmdletbinding()] 
     
    Param  
    (              
         [Parameter(ValueFromPipeline,  
           ValueFromPipelineByPropertyName,  
           HelpMessage='What computer name would you like to target?')]  
           $ComputerName = $env:COMPUTERNAME,  
          
        [Parameter(ValueFromPipeline,  
           ValueFromPipelineByPropertyName,  
           HelpMessage='What local group would you like to target to get a list of members from?')]   
         [ValidateNotNullOrEmpty()]  
         $GroupName = "Administrators", 
         
        [Parameter(Mandatory=$true,  
            HelpMessage='Do you want to list all the local groups on the computer(s)? Enter Yes or No')]   
        [ValidateSet('Yes', 'No', 'Y', 'N', IgnoreCase = $true)]  
        [string[]]$GroupList 
    )   
     
    Begin {} 
     
    Process  
    {             
        $NewLine = "`r`n" 
         
        Foreach ($Computer in $ComputerName) 
        { 
            $NewLine 
             
            $GetGroupList = (Get-WMIObject -ComputerName $Computer -Class Win32_Group -Filter "LocalAccount=True").Name | Out-String -OutVariable GetGroupList 
             
            If (Test-Connection -ComputerName $Computer -Count 1 -Quiet -ErrorAction Stop)  
            { 
                Write-Output "---------- Computer Name ----------" 
                 
                $NewLine 
                 
                $Computer 
                 
                $NewLine 
                 
                If ($GroupList -match "Yes" -or $GroupList -match "Y") 
                {                     
                    Write-Output "---------- List of Local Groups on $Computer ----------" 
                 
                    $NewLine 
                 
                    $GetGroupList 
                     
                    $NewLine 
                } 
             
                Foreach ($Group in $GroupName) 
                { 
                    $GetAdminGroupUsingSID = (Get-WMIObject -ComputerName $Computer -Class Win32_Group -Filter "LocalAccount=True and SID='S-1-5-32-544'").Name 
                     
                    Switch ($Group)   
                    {  
                        {  
                            $_ -match "Administrators"  
                        }  
                         
                        { 
                            If ($GetAdminGroupUsingSID -ne "Administrators") 
                            { 
                                Write-Output "---------- Administrators Group Renamed on $Computer ----------" 
                                 
                                $NewLine 
                                 
                                Write-Warning -Message "The script detected that the Administrators group has been renamed to:" 
                                 
                                $NewLine 
                                 
                                $GetAdminGroupUsingSID  
                                 
                                $NewLine 
                                 
                                $Group = $Group -replace "Administrators", "$GetAdminGroupUsingSID" 
                            } 
                        } 
                    } 
                     
                    $CheckGroupExist = $GetGroupList | Where-Object {$_ -match "$Group"} 
                     
                    If ($CheckGroupExist -eq $null) 
                    { 
                        $NewLine 
                         
                        Write-Warning -Message "The $Group group does not exist on $Computer" 
                         
                        $NewLine 
                    } 
                     
                    Else 
                    { 
                        Write-Output "---------- $Group Group Members on $Computer ----------" 
                     
                        $NewLine 
                         
                        Try 
                        { 
                            Add-Type -AssemblyName System.DirectoryServices.AccountManagement -ErrorAction Stop 
                        } 
                         
                        Catch 
                        {    
                            $NewLine  
                              
                            Write-Warning "The 'System.DirectoryServices.AccountManagement' namespace did NOT load successfully because $($_.Exception.Message)"  
                              
                            $NewLine  
                             
                            Write-Output "The script will now exit" 
                             
                            $NewLine 
                             
                            Write-Host "Press any key to continue ..." 
 
                            $Pause = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") 
                             
                            $NewLine 
                             
                            Exit 
                        } 
                         
                        $GetGroupInfo = @( 
 
                        $ContextType = [System.DirectoryServices.AccountManagement.ContextType]::Machine 
 
                        $PrincipalContext = New-Object -TypeName System.DirectoryServices.AccountManagement.PrincipalContext -ArgumentList $ContextType, $Computer 
 
                        $IdentityType = [System.DirectoryServices.AccountManagement.IdentityType]::SamAccountName 
 
                        $GroupPrincipal = [System.DirectoryServices.AccountManagement.GroupPrincipal]::FindByIdentity($PrincipalContext, $IdentityType, $Group) 
 
                        $GroupPrincipal)  
 
                        $GetGroupInfo.Members |  
                         
                        Select-Object @{N='ComputerOrDomainName'; E={$_.Context.Name}}, @{N='GroupMembers'; E={$_.samaccountName}} 
                    } 
                } 
            } 
             
            Else  
            {                  
                Write-Warning -Message "$Computer is offline or does not exist!"  
                  
                $NewLine  
            }  
        } 
    } 
     
    End {} 
}#EndFunction
