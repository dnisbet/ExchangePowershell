Function Get-Mailboxdata ($user){

$array = @{}

$a = Get-Mailbox -Identity $user | Select Name,ProhibitSendQuota,WhenMailboxCreated,PrimarySmtpAddress,IssueWarningQuota,Database
    $array.Name = $a.Name
	$array.Address = $a.PrimarySmtpAddress
    $array.Database = $a.Database
    $array.IssueWarningQuota =  $a.IssueWarningQuota
    $array.ProhibitSend = $a.ProhibitSendQuota
	$array.WhenMailboxCreated = $a.WhenMailboxCreated
$b = Get-MailboxStatistics -Identity $user | select DisplayName,StorageLimitStatus,TotalItemSize,TotalDeletedItemSize,LastLogonTime,ItemCount
$array.DisplayName = $b.DisplayName    
$array.StorageLimitStatus = $b.StorageLimitStatus
    $array.TotalSize = $b.TotalItemSize
    $array.ItemCount = $b.ItemCount
    $array.TotalDeletedItemSize = $b.TotalDeletedItemSize
	$array.LastLogonTime = $b.LastLogonTime
$c = Get-User $user | select ResetPasswordOnNextLogon
$array.ResetPasswordOnNextLogon = $c.ResetPasswordOnNextLogon
$array
}

Function Get-Queues () {
$m = Get-ClientAccessServer | get-queue | where-object {$_.MessageCount -gt 4} | sort-object $_.MessageCount | tee -variable queues | measure
$m.Count
$queues

}

Function Get-Cons () {
Get-ClientAccessServer | sort-object $_.Name | Get-CASActiveUsers
}

Function Get-ExBoot () {

Get-ExchangeServer | sort name | %{
    if(Test-Connection $_.name -Count 1 -Quiet) {
        $OS = Get-WmiObject -Class Win32_OperatingSystem -ComputerName $_.name            

        $uptime = (Get-Date) - $OS.ConvertToDateTime($OS.LastBootUpTime)            

        $report += "$($_.name) has been up for {0} days, {1} hours and {2} minutes." `
        -f $uptime.Days, $uptime.Hours, $uptime.Minutes + "`r"
    }
}
}

Function check-services () {

$servers = Get-ExchangeServer | sort-object $_.Name
foreach ($server in $servers) 
    {
        Write-Host "Checking" $server.name
        Test-ServiceHealth $server | ft Role,ServicesNotRunning -auto
    }
}

Function check-services () {

$servers = Get-ExchangeServer | sort-object $_.Name
foreach ($server in $servers) 
    {
        Write-Host "Checking" $server.name
        Test-ServiceHealth $server | ft Role,ServicesNotRunning -auto
    }
}

Function check-notrunningservices () {

$servers = Get-ExchangeServer | sort-object $_.Name
foreach ($server in $servers) 
    {
        $test = Test-ServiceHealth $server | ft Role,ServicesNotRunning -auto
        if ($test.ServicesNotRunning.count -gt 0)
        {
            Write-Host "Checking" $server.name
            Write-Host $test
        }
        else {
        Write-Host $server.name -nonewline; Write-Host " OK" -foregroundcolor "green"}
    }
}

Function check-dbs
{
$i=0
Write-Host "Checking Status of Databases..."
Get-MailboxServer | Get-MailboxDatabaseCopyStatus | ForEach {

    If ($_.Status -notmatch “Mounted” -and $_.Status -notmatch “Healthy” -or $_.ContentIndexState -notmatch “Healthy”)
    {
        Write-Host “`n$($_.Name) – Status: $($_.Status) – Index: $($_.ContentIndexState)” -ForegroundColor Red
    }
    Else { $i++ }
    }
    Write-Host "$i Databases OK"
}
