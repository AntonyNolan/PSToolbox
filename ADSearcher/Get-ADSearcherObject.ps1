# Quick and dirty ADSI query function (no RSAT needed).
# We use this to get the target DN when merging with an existing user.
# This should really be offloaded to another function.
# We don't fix the UPN, which ADMT seems to enjoy changing as well

function Get-ADSIObject {   
    <#
    .SYNOPSIS
	    Get AD object (user, group, etc.) via ADSI.
    .DESCRIPTION
	    Get AD object (user, group, etc.) via ADSI.
        Invoke a specify an LDAP Query, or search based on samaccountname and/or objectcategory
    .FUNCTIONALITY
        Active Directory
    .PARAMETER samAccountName
        Specific samaccountname to filter on
    .PARAMETER ObjectCategory
        Specific objectCategory to filter on
    
    .PARAMETER Query
        LDAP filter to invoke
    .PARAMETER Path
        LDAP Path.  e.g. contoso.com, DomainController1
        LDAP:// is prepended when omitted
    .PARAMETER Property
        Specific properties to query for
 
    .PARAMETER Limit
        If specified, limit results to this size
    .PARAMETER SearchRoot
        If specified, narrow search to this root
    .PARAMETER Credential
        Credential to use for query
        If specified, the Path parameter must be specified as well.
    .PARAMETER As
        SearchResult        = results directly from DirectorySearcher
        DirectoryEntry      = Invoke GetDirectoryEntry against each DirectorySearcher object returned
        PSObject (Default)  = Create a PSObject with expected properties and types
    .EXAMPLE
        Get-ADSIObject jdoe
        # Find an AD object with the samaccountname jdoe
    .EXAMPLE
        Get-ADSIObject -Query "(&(objectCategory=Group)(samaccountname=domain admins))"
        # Find an AD object meeting the specified criteria
    .EXAMPLE
        Get-ADSIObject -Query "(objectCategory=Group)" -Path contoso.com
        # List all groups at the root of contoso.com
    
    .EXAMPLE
        Echo jdoe, cmonster | Get-ADSIObject jdoe -property mail | Select -expandproperty mail
        # Find an AD object for a few users, extract the mail property only
    .EXAMPLE
        $DirectoryEntry = Get-ADSIObject TESTUSER -as DirectoryEntry
        $DirectoryEntry.put(‘Title’,’Test’) 
        $DirectoryEntry.setinfo()
        #Get the AD object for TESTUSER in a usable form (DirectoryEntry), set the title attribute to Test, and make the change.
    #>	
    [cmdletbinding(DefaultParameterSetName='SAM')]
    Param(
        [Parameter( Position=0,
                    ValueFromPipeline=$true,
                    ValueFromPipelineByPropertyName=$true,
                    ParameterSetName='SAM')]
        [string[]]$samAccountName = "*",

        [Parameter( Position=1,
                    ParameterSetName='SAM')]
        [string[]]$ObjectCategory = "*",

        [Parameter( ParameterSetName='Query',
                    Mandatory = $true )]
        [string]$Query = $null,

        [string]$Path = $Null,

        [string[]]$Property = $Null,

        [int]$Limit,

        [string]$SearchRoot,

        [System.Management.Automation.PSCredential]$Credential,

        [validateset("PSObject","DirectoryEntry","SearchResult")]
        [string]$As = "PSObject"
    )
   Begin 
    {
        #Define parameters for creating the object
        $Params = @{
            TypeName = "System.DirectoryServices.DirectoryEntry"
            ErrorAction = "Stop"
        }

        #If we have an LDAP path, add it in.
            if($Path){

                if($Path -notlike "^LDAP")
                {
                    $Path = "LDAP://$Path"
                }
            
                $Params.ArgumentList = @($Path)

                #if we have a credential, add it in
                if($Credential)
                {
                    $Params.ArgumentList += $Credential.UserName
                    $Params.ArgumentList += $Credential.GetNetworkCredential().Password
                }
            }
            elseif($Credential)
            {
                Throw "Using the Credential parameter requires a valid Path parameter"
            }

        #Create the domain entry for search root
            Try
            {
                Write-Verbose "Bound parameters:`n$($PSBoundParameters | Format-List | Out-String )`nCreating DirectoryEntry with parameters:`n$($Params | Out-String)"
                $DomainEntry = New-Object @Params
            }
            Catch
            {
                Throw "Could not establish DirectoryEntry: $_"
            }
            $DomainName = $DomainEntry.name

        #Set up the searcher
            $Searcher = New-Object -TypeName System.DirectoryServices.DirectorySearcher
            $Searcher.PageSize = 1000
            $Searcher.SearchRoot = $DomainEntry
            if($Limit)
            {
                $Searcher.SizeLimit = $limit
            }
            if($Property)
            {
                foreach($Prop in $Property)
                {
                    $Searcher.PropertiesToLoad.Add($Prop) | Out-Null
                }
            }
            if($SearchRoot)
            {
                if($SearchRoot -notlike "^LDAP")
                {
                    $SearchRoot = "LDAP://$SearchRoot"
                }

                $Searcher.SearchRoot = [adsi]$SearchRoot
            }

        #Define a function to get ADSI results from a specific query