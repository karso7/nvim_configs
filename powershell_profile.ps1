#########################################
### custom propmt that informs terminal CWD
function prompt {
    $loc = $executionContext.SessionState.Path.CurrentLocation;

      $out = ""
        if ($loc.Provider.Name -eq "FileSystem") {
              $out += "$([char]27)]9;9;`"$($loc.ProviderPath)`"$([char]27)\"
                }
                  $out += "PS $loc$('>' * ($nestedPromptLevel + 1)) ";
                    return $out

}

#########################################
### adding Worksapse env variable 
$WS = "C:\Work\Workspace"
$WSP = "C:\Work\Workspace\Python"
$WSMP = "C:\Work\Workspace\Electronics\micropython"

#########################################
### adding VS vars to powershel env vars -----
cmd.exe /c "call `"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat`" && set > %temp%\vcvars.txt"
    
Get-Content "$env:temp\vcvars.txt" | Foreach-Object {
	if ($_ -match "^(.*?)=(.*)$") {
		Set-Content "env:\$($matches[1])" $matches[2]
	}
}

#########################################
### pseudo sudo command
function sudo{
  param ([ScriptBlock]$code)
  $expandedCommand = $ExecutionContext.InvokeCommand.ExpandString($code.ToString())
  Write-Output $("sudo is executing: " + $expandedCommand) 
  Start-Process -FilePath pwsh -Verb RunAs -ArgumentList "-NoExit -Command $expandedCommand"
}


#########################################
### linking powershell profile with this file
function TryToSetupProfile(){
  if(Test-Path -Path "$PROFILE") {
    $linkType = (Get-Item "$PROFILE").LinkType
    if($linkType -ne "SymbolicLink"){
      Remove-Item -Force $PROFILE
    }
  }
  if(-not(Test-Path -Path "$PROFILE")) {
    sudo { 
      Split-Path -parent "$PROFILE"|Select-Object @{ name = 'Path'; expression = {`$_} }|New-Item -ItemType directory
      New-Item -Path "$PROFILE" -ItemType SymbolicLink -Value "$PSCommandPath" 
      }
  }
}

TryToSetupProfile


#########################################
### Create an alias for touch
function TouchFile() {
    $fileName = $args[0]
    # Check of the file exists
    if (-not(Test-Path $fileName)) {
        # It does not exist. Create it
        New-Item -ItemType File -Name $fileName
    }
    else {
        #It exists. Update the timestamp
        (Get-ChildItem $fileName).LastWriteTime = Get-Date
    }
}

# Check if the alias exists
if (-not(Test-Path -Path Alias:Touch)) {
    New-Alias -Name Touch TouchFile -Force
}


#########################################
### Create an alias for NvimUpdate
function UpdateNvim()
{
    $OutDir = "C:\Program Files\Neovim"
    $OutFile = "$OutDir\nvim-win64.zip"
    $OutFolder = "$OutDir\nvim-win64"

    Write-Output "Removing files from '$OutDir'"
    Remove-Item -Recurse "$OutDir\*" -Force -Exclude "update-nvim.ps1"

    Write-Output "Downloading new version ..."
    iwr -Uri "https://github.com/neovim/neovim/releases/download/nightly/nvim-win64.zip" -OutFile $OutFile

    Write-Output "Expanding archive new version '$OutFile'"
    Expand-Archive -Path $OutFile -DestinationPath $OutDir -Force

    Write-Output "Moving files to '$OutDir"
    Move-Item -Path "$OutFolder\*" -Destination $OutDir
}

# Check if the alias exists
if (-not(Test-Path -Path Alias:NvimUpdate)) {
    New-Alias -Name NvimUpdate UpdateNvim -Force
}


#########################################
# Use this function to add neovim to windows shell menu (RUN AS ADMIN) 
function TryToAddNvimToWindowsShellMenu(){
  Write-Host "Trying to setup files menu"
  if(-not(Test-Path -Path 'Registry::HKEY_CLASSES_ROOT\`*\shell\nvim')){
      New-Item -Path 'Registry::HKEY_CLASSES_ROOT\`*\shell' -Name "nvim" -Force
      New-Item -Path 'Registry::HKEY_CLASSES_ROOT\`*\shell\nvim' -Name "command" -Force
  }
  else {
    Write-Host 'Files Registry key already exist'
  }
  
  Set-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\`*\shell\nvim' -Name '(default)' -Value 'Open with NeoVim' -Force
  Set-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\`*\shell\nvim' -Name 'Icon' -Value 'C:\Windows\System32\wsl.exe,0' -Force
  Set-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\`*\shell\nvim\command' -Name '(default)' -Value "wt pwsh -NoExit -c `"& {Split-Path -parent '%1'`|cd && nvim '%1'}`"" -Force

  Write-Host "Trying to setup directory menu"
  if(-not(Test-Path -Path 'Registry::HKEY_CLASSES_ROOT\Directory\shell\nvim')){
      New-Item -Path 'Registry::HKEY_CLASSES_ROOT\Directory\shell' -Name "nvim" -Force
      New-Item -Path 'Registry::HKEY_CLASSES_ROOT\Directory\shell\nvim' -Name "command" -Force
  }
  else {
    Write-Host 'Directory Registry key already exist'
  }

  Set-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\Directory\shell\nvim' -Name '(default)' -Value 'Open with NeoVim' -Force
  Set-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\Directory\shell\nvim' -Name 'Icon' -Value 'C:\Windows\System32\wsl.exe,0' -Force
  Set-ItemProperty -Path 'Registry::HKEY_CLASSES_ROOT\Directory\shell\nvim\command' -Name '(default)' -Value "wt pwsh -NoExit -c `"& {Split-Path -parent '%1'`|cd && nvim}`"" -Force
}


#########################################
### Scan local IPs

function IPsLocalScan()
{
   $foundIps = @()
   $startIp = $args[0]
   Write-Output "Starting IPs scan, starting from IP: $startIp"
   $startIpParts = $startIp.Split(".")
   Write-Output "Last Start IP part: $($startIpParts[3])"
   for ($i = ($startIpParts[3] -as[int]); $i -lt 255; $i++)
   {
        $testedIP = "$($startIpParts[0]).$($startIpParts[1]).$($startIpParts[2]).$i"
        ping -n 1 -l 1 -w 10 $testedIP
        if( $LASTEXITCODE -eq 0)
        {
            $foundIps += $testedIP
        }
   }
   Write-Output ""   
   Write-Output "#################################################"
   Write-Output "Found IPs:"
   Write-Output "$($foundIps -join [Environment]::NewLine)"
   Write-Output "#################################################"
}

if (-not(Test-Path -Path Alias:Test-IPsLocalScan)) {
    New-Alias -Name Test-IPsLocalScan IPsLocalScan -Force
}
