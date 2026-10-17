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
### pseudo sudo command
function sudo{
  param ([String]$code)
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
### Create an alias for slime_text
function SublimeText() {
    $path = $args[0]
    start "C:\Program Files\Sublime Text\sublime_text.exe" $path
}

# Check if the alias exists
if (-not(Test-Path -Path Alias:sublime)) {
    New-Alias -Name sublime SublimeText -Force
}


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
function Test-NvimPrerequisites()
{
    $allOk = $true
    Write-Output "Checking essential tools for Neovim ..."

    # git - required by Lazy.nvim for plugin management
    $git = Get-Command git -ErrorAction SilentlyContinue
    if ($git) {
        Write-Output ("  [OK]   git     : {0}" -f $git.Source)
    }
    else {
        Write-Output "  [MISS] git     : required by Lazy.nvim - install 'choco install git'"
        $allOk = $false
    }

    # ripgrep (rg) - required by Telescope live grep / grug-far
    $rg = Get-Command rg -ErrorAction SilentlyContinue
    if ($rg) {
        Write-Output ("  [OK]   ripgrep : {0}" -f $rg.Source)
    }
    else {
        Write-Output "  [MISS] ripgrep : required by Telescope live grep - 'choco install ripgrep'"
        $allOk = $false
    }

    # unzip - required by Mason / Expand-Archive workflows
    $unzip = Get-Command unzip -ErrorAction SilentlyContinue
    if ($unzip) {
        Write-Output ("  [OK]   unzip   : {0}" -f $unzip.Source)
    }
    else {
        Write-Output "  [MISS] unzip   : required by Mason - 'choco install unzip'"
        $allOk = $false
    }

    # fd - optional but used by Telescope and snacks pickers
    $fd = Get-Command fd -ErrorAction SilentlyContinue
    if ($fd) {
        Write-Output ("  [OK]   fd      : {0}" -f $fd.Source)
    }
    else {
        Write-Output "  [MISS] fd      : used by Telescope/snacks file finder - 'choco install fd'"
        $allOk = $false
    }

    # Nerd Font check - a font family name containing "Nerd Font" must be installed
    $fontPaths = @(
      "$env:WINDIR\Fonts"
      "$env:LOCALAPPDATA\Microsoft\Windows\Fonts"
    )
    $nerdFont = Get-ChildItem -Path $fontPaths -File -ErrorAction SilentlyContinue |
      Where-Object { $_.Name -match 'Nerd' } |
      Select-Object -First 1

    if ($nerdFont) {
        Write-Output ("  [OK]   NerdFont: {0}" -f $nerdFont.Name)
    }
    else {
        Write-Output "  [MISS] NerdFont: required for icons in statusline/telescope - https://www.nerdfonts.com/font-downloads"
        $allOk = $false
    }

    if ($allOk) {
        Write-Output "All prerequisites satisfied."
    }
    else {
        Write-Output "Some prerequisites are missing - Neovim will still work but some plugins may misbehave."
    }
    return $allOk
}

function UpdateNvim()
{
    Test-NvimPrerequisites | Out-Null

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
# Check if the alias exists
if (-not(Test-Path -Path Alias:NvimTestPrerequisites)) {
    New-Alias -Name NvimTestPrerequisites Test-NvimPrerequisites
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
