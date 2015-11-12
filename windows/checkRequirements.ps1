
Function Test-CommandExists($command)
{
    $oldPreference = $ErrorActionPreference
    $ErrorActionPreference = 'stop'
    try {if(Get-Command $command){$TRUE}}
    Catch {$FALSE}
    Finally {$ErrorActionPreference=$oldPreference}
} #end function test-CommandExists

Function Test-Requirements($requirements)
{
    $missing_requirements = @()
    Foreach($command in $requirements)
    {
        if (-Not (Test-CommandExists($command)))
        {
            $missing_requirements += $command
        }
    }

    if ($missing_requirements.Count -gt 0)
    {
       echo "The following requirements are missing. You need to install them first: "
       $missing_requirements
       exit 1
    }
}

Test-Requirements(@("python", "npm", "makensis"))  # add gpg and git here later

if (-NOT($env:VS90COMNTOOLS))
{
    echo "Visual Studio is not currently installed!"
    exit 1
}

$pythonCommand = Get-Command python
$pythonPath = Split-Path $pythonCommand.source

if ((Test-Path $pythonPath\scripts\virtualenv.exe) -eq 0)
{
    echo "virtualenv is not currently installed!"
    exit 1
}
