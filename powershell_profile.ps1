### adding VS vars to powershel env vars -----
cmd.exe /c "call `"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvars64.bat`" && set > %temp%\vcvars.txt"
    
Get-Content "$env:temp\vcvars.txt" | Foreach-Object {
	if ($_ -match "^(.*?)=(.*)$") {
		Set-Content "env:\$($matches[1])" $matches[2]
	}
}


### pseudo sudo command
function sudo{
  param ([ScriptBlock]$code)
  $expandedCommand = $ExecutionContext.InvokeCommand.ExpandString($code.ToString())
  Write-Output $("sudo is executing: " + $expandedCommand) 
  Start-Process -FilePath powershell.exe -Verb RunAs -ArgumentList "-Command $expandedCommand"
}


### linking powershell profile with this file
if(Test-Path -Path "$PROFILE") {
  $linkType = (Get-Item "$PROFILE").LinkType
  if($linkType -ne "SymbolicLink"){
    Remove-Item -Force $PROFILE
  }
}
if(-not(Test-Path -Path "$PROFILE")) {
  sudo { New-Item -Path "$PROFILE" -ItemType SymbolicLink -Value "$PSCommandPath" }
}


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



