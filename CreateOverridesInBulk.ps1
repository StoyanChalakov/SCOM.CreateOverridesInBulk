
<#
.SYNOPSIS
    Powershell script  to disable all System Center Operations Manager (SCOM) rules and monitors from a source management pack and put those in an override target management pack.
.DESCRIPTION
    The script gets all rules and monitors from a source management pack and disables them by creating overrides in a target management pack.
    Each rule or monitor is overrides for the respective class it is targeted to.
    Both the target and the source management packs have to be specified in the script.
.NOTES
    Author       : Stoyan Chalakov  (https://www.pohn.ch/blog/)
    Requires     : Operations Manager Powershell
    Version      : 1.1
    Original Date: 10 September 2024
#>

# Load Operations Manager module if not already loaded
Import-Module OperationsManager -ErrorAction SilentlyContinue

# Define the source and target Management Packs
try {
    $SourceMP = Get-SCOMManagementPack -DisplayName "Security Monitoring"
    $TargetMP = Get-SCOMManagementPack -DisplayName "Prefix OR Security Monitoring"
} catch {
    Write-Error "Failed to retrieve management packs: $_"
    exit
}

# Get all rules and monitors from the source Management Pack
try {
    $Rules = Get-SCOMRule -ManagementPack $SourceMP
    $Monitors = Get-SCOMMonitor -ManagementPack $SourceMP
} catch {
    Write-Error "Failed to retrieve rules or monitors: $_"
    exit
}

#Create a hashtable of all the SCOM classes for faster retreival based on Class ID. This part has been stoledn from Kevin Holman's blog post: https://blogs.technet.microsoft.com/kevinholman/2016/11/02/using-powershell-to-disable-a-rule-or-monitor-in-scom/
$ClassHT = @{}
try {
    $Classes = Get-SCOMClass
    foreach ($Class in $Classes) {
        $ClassHT[$Class.Id] = $Class
    }
} catch {
    Write-Error "Failed to retrieve SCOM classes: $_"
    exit
}

# Disable all rules by creating overrides in the target Management Pack

foreach ($Rule in $Rules) {
    try {
        # Get the targeted class of the rule and other properties
        [string]$RuleTargetDisplayName = ($ClassHT.($Rule.Target.Id.Guid)).DisplayName
        $RuleTargetedClass = Get-SCOMClass -DisplayName $RuleTargetDisplayName
        
        # Do the actual override
        Disable-SCOMRule -Class $RuleTargetedClass -Rule $Rule -ManagementPack $TargetMP -Enforce
    } catch {
        Write-Error "Failed to disable rule $($Rule.DisplayName): $_"
    }
}

# Disable all monitors by creating overrides in the target Management Pack
foreach ($Monitor in $Monitors) {
    try {
        # Get the targeted class of the rule and other properties
        [string]$MoniTargetDisplayName = ($ClassHT.($Monitor.Target.Id.Guid)).DisplayName
        $MoniTargetedClass = Get-SCOMClass -DisplayName $MoniTargetDisplayName

        # Do the actual override 
        Disable-SCOMMonitor -Class $MoniTargetedClass -Monitor $Monitor -ManagementPack $TargetMP -Enforce
    } catch {
        Write-Error "Failed to disable monitor $($Monitor.DisplayName): $_"
    }
}