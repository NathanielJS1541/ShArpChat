<#
.SYNOPSIS
    A cleanup script for git repos containing .NET projects.

.DESCRIPTION
    Searches for 'bin/' and 'obj/' folders under the 'src/' directory of the current git repo.
    Thanks to the use of 'git.exe', this scipt can be called by a relative path from any directory
    within the git repo.

    Note that this script requires the following:
    - 'git.exe' to be on the PATH.
    - The source code in the repo should be in a 'src/' folder under the repo root.

    This is useful when Visual Studio refuses to clean its temporary build files up properly, and
    solves this issue by indiscriminately destroying them all...

.INPUTS
    None

.OUTPUTS
    None

.EXAMPLE
    .\solution_cleanup.ps1

.EXAMPLE
    .\utils\solution_cleanup.ps1

.NOTES
    Author: Nathaniel Struselis
    GitHub: https://github.com/NathanielJS1541
    Source: https://github.com/NathanielJS1541/ShArpChat/blob/main/utils/solution_cleanup.ps1
#>

# Variables storing the old state of the terminal window.
[string] $oldWindowTitle = $null

# Variables storing information about git.
[bool] $isGitFound = $false
[bool] $isGitRepo = $false

# Variables storing details of the git repo.
[string] $repoRoot = $null
[string] $repoName = $null
[string] $scriptTitle = $null

<#
.SYNOPSIS
    Set up the PowerShell environment for the script to run.

.DESCRIPTION
    This should be run at the very start of the script.

    This function does the following:
    - Store the current $Host.UI.RawUI.WindowTitle, to be restored later.
    - Writes a blank line to separate the script output from previous commands.
#>
function InitialiseSession {
    # Store the current PowerShell window title, so it can be restored when the script ends.
    $oldWindowTitle = $Host.UI.RawUI.WindowTitle

    # Separate the script output from any commands above with a new line.
    Write-Host ""
}

<#
.SYNOPSIS
    Update details for the script session, such as the window title.

.DESCRIPTION
    This should only be run after calling 'InitialiseSession', so that the previous window title
    can be restored with 'RestoreSessionDetails' or 'EndSession'.

.EXAMPLE
    UpdateSessionDetails -WindowTitle "Custom Window Title"
#>
function UpdateSessionDetails {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        # The title to be displayed on the PowerShell window.
        $WindowTitle
    )

    # Only try and update the window title if a valid title has been passed in.
    if (![string]::IsNullOrWhiteSpace($WindowTitle)){
        # Set the window title to the value passed in as a parameter.
        # Note: This only works in PowerShell!
        $Host.UI.RawUI.WindowTitle = $WindowTitle
    }
}

<#
.SYNOPSIS
    Restore the PowerShell session state saved by 'InitialiseSession'.

.DESCRIPTION
    'InitialiseSession' should be called before calling this function, othwrwise the wwindow title
    will not be altered.

    This function shouldn't be called directly. Use 'EndSession' instead.
#>
function RestoreSessionDetails {
    # Only try to restore the previous window title if its state was saved previously.
    if (![string]::IsNullOrWhiteSpace($oldWindowTitle)) {
        UpdateSessionDetails -WindowTitle $oldWindowTitle
    }
}

<#
.SYNOPSIS
    End the script session.

.DESCRIPTION
    This function does the following:
    - Restores $Host.UI.RawUI.WindowTitle to the value from before the script session.
    - Writes a blank line to separate the script output from any following.

    'InitialiseSession' must be called before this function will work.
#>
function EndSession {
    # Restore the PowerShell session to its state before 'InitialiseSession' was called.
    RestoreSessionDetails

    # Print a final separator between the scipt and the next command on the Terminal.
    Write-Host ""
}

<#
.SYNOPSIS
    Search the PATH for the specified command.

.DESCRIPTION
    Returns a bool representing whether the specified command was found on the PATH.

.OUTPUTS
    A System.Bool. $true if the command was found on the path. $false otherwise.

.EXAMPLE
    CommandExistsOnPath -Command "git"
#>
function CommandExistsOnPath {
    param (
        [Parameter(Mandatory=$true)]
        [string]
        # The name of the command to search for on the PATH.
        $Command
    )

    return ($null -ne (Get-Command $Command -ErrorAction SilentlyContinue))
}

<#
.SYNOPSIS
    Pretty-print a title for the script.

.DESCRIPTION
    Prints the specified title for the script with an underline of the same length.

    If no valid title is provided, it defaults to "Solution Cleanup Script".

.EXAMPLE
    PrintScripTitle

.EXAMPLE
    PrintScripTitle -Title "Useless Scipt Cleanup"
#>
function PrintScripTitle {
    param (
        [Parameter(Mandatory=$false)]
        [string]
        # The title to be displayed for the script. Defaults to $null.
        $Title = $null
    )

    # If a title has not been provided, use the default.
    if ([string]::IsNullOrWhiteSpace($Title)) {
        $Title = "Solution Cleanup Script"
    }

    # Display a title to the user. The underline is generated to the same length as the title.
    Write-Host $Title
    Write-Host "$(New-Object string ('-', $Title.Length))"
}

# Main script body. The try-finally is used to ensure the session is clened up even in the event of
# an exception.
try {
    # Initialise the script session.
    InitialiseSession

    # Check for the existence of 'git.exe' on the PATH.
    $isGitFound = CommandExistsOnPath -Command "git"

    # If git was found, use it to detect whether the current directory is within a git repo.
    if ($isGitFound) {
        $isGitRepo = $(git rev-parse --is-inside-work-tree) -eq "true"
    }

    # If the current directory is within a git repo, get some information about the repo.
    if ($isGitRepo) {
        # Get the absolute path to the root of the git repo.
        $repoRoot = git rev-parse --show-toplevel

        # Split the path, and save the last item as the name of the repo.
        $repoName = Split-Path $repoRoot -Leaf

        # Create a title for the script using the repo name.
        $scriptTitle = "$repoName Solution Cleanup"

        # Update the current PowerShell session details with the new script title.
        UpdateSessionDetails -WindowTitle $scriptTitle
    }

    # Print the title for the script. This will output the default value if 'git.exe' wasn't found, or
    # the script was not run from within a repo. If the repo name was found, the title will be
    # constructed from the repo name.
    PrintScripTitle -Title $scriptTitle

    # Now the script has a title, display that requirements have been met to the user, or throw
    # custom exceptions to drop into the "finally" block straight away.
    if (!$isGitFound) {
        throw "git.exe not found."
    }
    else {
        Write-Host "git.exe found on PATH." -ForegroundColor Green
    }

    if (!$isGitRepo) {
        throw "Could not find git repo from $PWD. Please cd into the git repo."
    }
    else {
        Write-Host "Found git repo: $repoName" -ForegroundColor Green
    }

    # Create the path to the source directory from the repo path. This is where the solution
    # cleanup should run.
    $srcDir = Join-Path -Path $repoRoot -ChildPath "\src\"

    # Ensure the "src/" directory exists before trying to scan for directories to delete.
    if (Test-Path $srcDir -ErrorAction SilentlyContinue) {
        Write-Host "Found src path: $srcDir." -ForegroundColor Green

        # Find all of the "bin/" and "obj/" folders to delete within the "src/" directory.
        Write-Host "Scanning for 'bin/' and 'obj/' folders in src path..." -ForegroundColor Cyan
        $files = Get-Childitem -Path $srcDir -Recurse | Where-Object {($_.Name -ilike "obj") -or ($_.Name -ilike "bin")}
        $total = $files.Length
    }
    else {
        # If the "src/" directory does not exist, set $total to -1 to differentiate between not
        # having any files to delete and not being able to find the directory to search.
        $total = -1
    }

    # Check whether there is anything to delete. Note that if Test-Path $srcDir returned false
    # above, $total will be -1 here, which will also fail the greater than check.
    if ($total -gt 0) {
        Write-Host "Found $total folders" -ForegroundColor Yellow

        # Loop through every folder that was found and delete it.
        for ($i = 0; $i -lt $total; $i++ ) {
            # Work out the percentage completion of the delete operation.
            $progress = [int](($i / $total) * 100)

            # Use Write-Progress to display a progress bar.
            Write-Progress -Activity "Deleting folders" -Status "$progress% Complete:" -PercentComplete $progress

            # Sanity check: Ensure the file exists before trying to delete it!
            if (Test-Path -Path $files[$i]) {
                # Remove the directory and all its contents.
                Remove-Item $files[$i] -Force -Recurse
            }
        }

        Write-Host "Deleting folders complete." -ForegroundColor Green
    }
    elseif ($total -eq -1) {
        # If $total = -1, the "src/" directory wasn't found. Print the current directory to try and
        # help diagnose the issue.
        Write-Host "Could not find the src directory from $PWD. Does the repo have a 'src/' folder?" -ForegroundColor Red
    }
    else {
        Write-Host "Nothing to delete!" -ForegroundColor Green
    }
}
finally {
    # Always clean up the session.
    EndSession
}