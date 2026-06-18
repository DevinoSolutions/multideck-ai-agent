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

# Final path segment of a dir, tolerant of forward- or back-slashes. This is the
# string VS Code puts in its window title (the opened folder's name), so it - NOT
# a user-supplied 'title' - is what the tiler must match a 'code' window by.
function Get-MdLeafName {
    param([Parameter(Mandatory = $true)][string]$Path)
    return Split-Path ("$Path" -replace '/', '\').TrimEnd('\') -Leaf
}

# Build the 'ssh -t <host> "..."' command that runs an agent in a remote dir.
# With $Shell set (default 'bash -lc') the remote command is wrapped in a login
# shell so the remote PATH (nvm/asdf/Homebrew/~/.local/bin) is sourced.
function Build-MdSshCommand {
    param(
        [Parameter(Mandatory = $true)][string]$SshHost,
        [Parameter(Mandatory = $true)][string]$RemoteDir,
        [Parameter(Mandatory = $true)][string]$ToolCmd,
        [string]$Shell = 'bash -lc'
    )
    $inner  = "cd $RemoteDir && $ToolCmd"
    $remote = if ($Shell) { "$Shell '$inner'" } else { $inner }
    return "ssh -t $SshHost `"$remote`""
}

# Build the Start-Process cmd ArgumentList for opening VS Code, locally or - when
# $SshHost is set - over Remote-SSH (code --remote ssh-remote+<host> <dir>).
function Build-MdCodeArgs {
    param(
        [Parameter(Mandatory = $true)][string]$Dir,
        [string]$SshHost
    )
    if ($SshHost) {
        return @('/c', 'code', '--remote', "ssh-remote+$SshHost", "`"$Dir`"")
    }
    return @('/c', 'code', "`"$Dir`"")
}
