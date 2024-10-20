# SCOM.CreateOverridesInBulk

.SYNOPSIS
    Powershell script  to disable all System Center Operations Manager (SCOM) rules and monitors from a source management pack and put those in an override target management pack.
.DESCRIPTION
    The script gets all rules and monitors from a source management pack and disables them by creating overrides in a target management pack.
    Each rule or monitor is overrides for the respective class it is targeted to.
    Both the target and the source management packs have to be specified in the script.
.NOTES
    Author       : Stoyan Chalakov  (https://www.pohn.ch/blog/)
    Requires     : Operations Manager Powershell
    Version      : 1.0
    Original Date: 10 September 2024
