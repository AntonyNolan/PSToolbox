Echo "Welcome to Exchange Everything's Environment Report - Moamen Hany Version 1"
#M
##O
###A
####M
#####E
######N
#######(MOAMEN HANY - Exchange Everything's Environment Report v1)######
#####################'www.momenhany.com'############################
#########################'+201143739545'##############################
#####################'it.momenhany@hotmail.com'#######################"

mkdir c:\MoamenHanyExchangeReport
Cd "c:\MoamenHanyExchangeReport"
Get-date > .\Date.txt
#Exchange Organization/Servers Configurations
Echo "#Exchange Everything's Environment Report - Moamen Hany";Echo "#Exchange Organization/Configurations"; Get-OrganizationConfig | ft name | out-file .\ExchangeOrg.txt
Echo "#Exchange Server /Configurations";Get-ExchangeServer | ft Identity,Site,ServerRole,Edition,ExchangeVersion -autosize| out-file .\ExchangeServers.txt 
Echo "#Exchange Organization Relationship Configurations";Get-OrganizationRelationship |ft DomainNames,FreeBusyAccessEnabled,Enabled,Isvalid -autosize | out-file .\OrganizationRelationship.txt -width 100
#AD Forest/Domain Function Level
Echo "#Active Directory Forest Function Level";(Get-ADForest).ForestMode | out-file .\ADForestFL.txt
Echo "#Active Directory Domain Function Level";(Get-ADDomain).DomainMode | out-file .\ADDomainFL.txt
#Exchange Virtual Directory
Echo "#Exchange VD ECP";Get-ECPVirtualDirectory | Format-List Name,InternalURL,ExternalURL| out-file .\ECP.txt 
Echo "#Exchange VD OWA";Get-OWAVirtualDirectory | Format-List Name,InternalURL,ExternalURL | out-file .\OWA.txt
Echo "#Exchange VD OAB";Get-OABVirtualDirectory | Format-List Name,InternalURL,ExternalURL | out-file .\OAB.txt
Echo "#Exchange VD MAPI";Get-MAPIVirtualDirectory | Format-List Name,InternalURL,ExternalURL | out-file .\MAPI.txt
Echo "#Exchange VD EWS";Get-WebServicesVirtualDirectory | Format-List Name,InternalURL,ExternalURL,MRSProxyEnabled | out-file .\EWS.txt
Echo "#Exchange VD ActiveSync";Get-ActiveSyncVirtualDirectory | Format-List Name,InternalURL,ExternalURL| out-file .\AS.txt
#Exchange AutoDiscover
Echo "#Exchange VD Autodiscover";Get-ClientAccessService | ft Name,AutoDiscoverServiceInternalUri | out-file .\Autodiscover.txt
Echo "#Exchange VD Legacy Autodiscover";Get-ClientAccessServer | ft Name,AutoDiscoverServiceInternalUri | out-file .\LagacyAutodiscover.txt
#Exchange Anyware and Mapi Status
Echo "#Exchange OutlookAnyWare Configuration";Get-OutlookAnywhere | ft IsValid,Server,IISAuthenticationMethods,ExternalHostName,InternalHostName| out-file .\AnyWare.txt
Echo "#Exchange MAPI Status";Get-OrganizationConfig | ft ID,MapiHttpEnabled | out-file .\MapiStatus.txt
#Exchange Mailbox -30 Last Login
Echo "#Exchange Mailbox -30 Last Login";Get-mailbox -resultsize unlimited |Get-MailboxStatistics | where {$_.LastLogonTime -lt (get-date).AddDays(-30)} | ft displayName,lastlogontime,lastloggedonuseraccount,servername | out-file .\Last30DayLogin.txt
#Exchange Mailbox top10 Size
Echo "#Exchange Mailbox top10 Size";Get-Mailbox  -ResultSize Unlimited| Get-MailboxStatistics | Sort-Object TotalItemSize -descending |Select-Object DisplayName,ItemCount,@{name="MailboxSize";exp={$_.totalitemsize}} -first 10 | out-file .\FirstSize10.txt
#Exchange SSL Certificate
Echo "#Exchange SSL Certificate";Get-ExchangeCertificate | ft Notafter,publickeysize,services,subject,certificatedomains |out-file .\Certificates.txt
#Exchange Mail Flow Configurations
Echo "#Exchange Mail Flow Receive Connector";Get-ReceiveConnector | ft Name,Isvalid,PermissionGroups | out-file .\ReceiveConnectors.txt -width 100
Echo "#Exchange Mail Flow Send Connector";Get-SendConnector | ft name,Maxmessagesize,port,sourcetransportservers,addressspaces,smarthosts | out-file .\SendConnectors.txt -width 100
Echo "#Exchange Accepted Domains";Get-AcceptedDomain | out-file .\AcceptedDomain.txt
Echo "#Exchange Remote Domains";Get-RemoteDomain  | out-file .\RemoteDomain.txt
Echo "#Exchange Transport Queue";Get-TransportServer | Get-Queue | out-file .\Queue.txt -width 100
Echo "#Exchange CAS Array";Get-ClientAccessArray | ft Name,FQDN,Members | out-file .\CASArray.txt
#Exchange Mailboxes
Echo "#Exchange Mailbox Arbitration Status" Get-Mailbox -Arbitration | ft isvalid,name |out-file .\ArbitrationMailboxes.txt
Echo "#Exchange All Mailbox Count";Get-Mailbox -ResultSize Unlimited | measure | Out-File .\MailboxCount.txt
#Exchange Mailbox Databases
Echo "#Exchange Mailbox Database Status";Get-MailboxDatabase -Status | Format-List Name,DatabaseSize,AvailableNewMailboxSpace,IsValid,LastFullBackup,ProhibitSendQuota,Server,Mounted,CircularLoggingEnabled,InvalidDatabaseCopies,Ismailboxdatabase,MasterServerOrAvailabilityGroup,rpcclientaccessserver|out-file .\MailboxDatabases.txt
Echo "#Exchange Mailbox Database Copy Status";Get-MailboxDatabasecopystatus | out-file .\MailboxDatabaseCopyStatus.txt
#Exchange All Mailbox Information CSV out
Get-mailbox -resultsize unlimited   |Get-MailboxStatistics | Export-csv .\ALLMailboxStatistics.csv -encoding unicode
Get-mailbox -resultsize unlimited  | Export-csv .\ALLMailbox.csv -encoding unicode
#Exchange Testing
Echo "#Exchange Test Roles Status";Get-ExchangeServer | Test-ServiceHealth | ft Role,RequiredServicesRunning | out-file .\TestHealth.txt

#Exchange DNS Records
New-PSSession
Echo "#Exchange DNS MX Records";Resolve-DnsName -Name Alnafitha.com -Type MX -Server 8.8.8.8 | out-file .\MX.txt
Echo "#Exchange DNS SPF Records";Resolve-DnsName -Name Alnafitha.com -Type TXT -Server 8.8.8.8 | out-file .\SPF.txt

Echo "Welcome to Exchange Everything's Environment Report - Moamen Hany Version 1
#M
##O
###A
####M
#####E
######N
#######(MOAMEN HANY - Exchange Everything's Environment Report v1)######
#####################'www.momenhany.com'############################
#########################'+201143739545'##############################
#####################'it.momenhany@hotmail.com'#######################
# The following Exchange script can export most of important information from Exchange 2007,2010,2013,2016 to Exchange Administrator as the below sections
#Exchange Organization/Servers Configurations
#AD Forest/Domain Function Level
#Exchange Virtual Directory
#Exchange AutoDiscover
#Exchange Anyware and Mapi Status
#Exchange SSL Certificate
#Exchange Mail Flow Configurations
#Exchange DNS Records
#Exchange Mailboxes
#Exchange Mailbox Databases
#Exchange Mailbox -30 Last Login
#Exchange Mailbox top10 Size
#Exchange Testing
#Script will create a Dir in the common location C:\ Drive with Name 'MoamenHanyExchangeReport' and then switch in the Dir, after that the script with run each section #powershell commands in Exchange Powershell Console, some commands will add new PS-Session to open Windows Powershell console to run the remain commands that #can't do through Exchange powershell console.
#You can monitor the batch while running and can see which section or Phase batch working.
#Merge and output = after all commands finished you will merge every TXT files in single Report with that organized by 'Moamen Hany' and the report will open automatically #using Windows Notepad.
#Other files Exchange Mailbox and Mailboxstatistcs with CSV files will generated and open automatically in MS Office Excel.
#Script run time = is according the environment resources and objects.
#Script wrote = Moamen Hany | Contact it.momenhany@hotmail.com | +201143739545 | www.momenhany.com =============================================================================================" | out-file .\Header.TXT

#Merge Files
Type Date.txt,Header.TXT,ExchangeOrg.txt,ExchangeServers.txt,ADForestFL.txt,ADDomainFL.txt,OrganizationRelationship.txt,AcceptedDomain.txt,RemoteDomain.txt,Certificates.txt,LagacyAutodiscover.txt,Autodiscover.txt,ECP.txt,OWA.txt,OAB.txt,MAPI.txt,EWS.txt,AS.txt,AnyWare.txt,MapiStatus.txt,ReceiveConnectors.txt,SendConnectors.txt,MX.txt,SPF.TXT,Queue.txt,MailboxCount.txt,ArbitrationMailboxes.txt,MailboxDatabases.txt,CASArray.txt,MailboxDatabaseCopyStatus.txt,FirstSize10.txt,Last30DayLogin.txt,TestHealth.txt   > c:\MoamenHanyExchangeReport\MoamenHanyReport.TxT
#Open Report
Notepad.exe "c:\MoamenHanyExchangeReport\MoamenHanyReport.TXT"



$file = "c:\MoamenHanyExchangeReport\MoamenHanyReport.TXT"
$smtpServer = "wmail.miahona.com"
$att = new-object Net.Mail.Attachment($file)
$msg = new-object Net.Mail.MailMessage
$smtp = new-object Net.Mail.SmtpClient($smtpServer)
$msg.From = "mhany@alnafitha.com"
$msg.To.Add("mhany@alnafitha.com")
$msg.Subject = "Exchange Everything Report - Moamen Hany"
$msg.Body = "Exchange Everything Report - Moamen Hany"
$msg.Attachments.Add($att)
$smtp.Send($msg)
$att.Dispose()