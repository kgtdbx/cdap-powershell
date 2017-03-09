####################################################################################################
##
##  BOILER PLATE SCRIPT ELEVATION 
##  https://blogs.msdn.microsoft.com/virtual_pc_guy/2010/09/23/a-self-elevating-powershell-script/
##
####################################################################################################

# Get the ID and security principal of the current user account
$myWindowsID=[System.Security.Principal.WindowsIdentity]::GetCurrent()
$myWindowsPrincipal=new-object System.Security.Principal.WindowsPrincipal($myWindowsID)
 
# Get the security principal for the Administrator role
$adminRole=[System.Security.Principal.WindowsBuiltInRole]::Administrator
 
# Check to see if we are currently running "as Administrator"
if ($myWindowsPrincipal.IsInRole($adminRole))
   {
   # We are running "as Administrator" - so change the title and background color to indicate this
   $Host.UI.RawUI.WindowTitle = $myInvocation.MyCommand.Definition + "(Elevated)"
   $Host.UI.RawUI.BackgroundColor = "DarkBlue"
   clear-host
   }
else
   {
   # We are not running "as Administrator" - so relaunch as administrator
   
   # Create a new process object that starts PowerShell
   $newProcess = new-object System.Diagnostics.ProcessStartInfo "PowerShell";
   
   # Specify the current script path and name as a parameter
   $newProcess.Arguments = $myInvocation.MyCommand.Definition;
   
   # Indicate that the process should be elevated
   $newProcess.Verb = "runas";
   
   # Start the new process
   [System.Diagnostics.Process]::Start($newProcess);
   
   # Exit from the current, unelevated, process
   exit
   }
   
############################################################################################
<# 
   Script creates a symbolic link to cdap sdk
   Goal is to switch between homes and cdap versions quickly
   Creating symbolicLink requires administrator privlages
   cdap_sdk is used for evaluating path and removing existing link
   Only the cdap_home and link_name are used to create the link   
   Script does not test for actual sdk, it just deletes and recreates a link
#>

$global:i=0

$cdap_home='c:\app\cdap'
$link_name="sdk"
$cdap_sdk="$cdap_home\$link_name"

# Check if CDAP is running
<# unimplimented #>

# Get directory list
$cdap = get-ChildItem $cdap_home -Directory `
| Where-Object -FilterScript {($_.Name -like 'cdap*')} `
| Select @{Name="select";Expression={$global:i++;$global:i}},Name,FullName

$cdap | format-table |out-string | % {write-host $_}
[int]$selection = Read-Host 'Enter selection'

if ($selection) { 
if (test-path $cdap_sdk) {cmd /c "rmdir $cdap_sdk"}

#Create Link - using cdap_home and link_name
$link = $cdap | Where-Object {$_.select -eq $selection}
$link | format-table |out-string | % {write-host $_}
New-Item -ItemType SymbolicLink -Path $cdap_home -Name $link_name -Value $link.FullName
} else
{write-output "Nothing selected"}


Write-Host -NoNewLine "Press any key to continue..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")








