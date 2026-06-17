<#
.SYNOPSIS
    Pure, side-effect-free command builders for multideck's remote (SSH) support.
    Kept separate from multideck.ps1 so they can be unit-tested without launching
    windows or running the main script. Dot-sourced by multideck.ps1.
#>

# Remote working directory for a project: remotePath when set, else path.
function Get-MdRemoteDir {
    param([Parameter(Mandatory = $true)]$Project)
    if ($Project.remotePath) { return "$($Project.remotePath)" }
    return "$($Project.path)"
}
