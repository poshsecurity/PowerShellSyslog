$script:ModuleName = 'Posh-SYSLOG'

# Removes all versions of the module from the session before importing
Get-Module $ModuleName | Remove-Module

$ModuleBase = Split-Path -Parent $MyInvocation.MyCommand.Path

# For tests in .\Tests subdirectory
if ((Split-Path $ModuleBase -Leaf) -eq 'Tests') {
    $ModuleBase = Split-Path $ModuleBase -Parent
}

## This variable is for the VSTS tasks and is to be used for referencing any mock artifacts
$Env:ModuleBase = $ModuleBase

Import-Module $ModuleBase\$ModuleName.psd1 -PassThru -ErrorAction Stop | Out-Null

# InModuleScope runs the test in module scope.
# It creates all variables and functions in module scope.
# As a result, test has access to all functions, variables and aliases
# in the module even if they're not exported.
InModuleScope $script:ModuleName {
    Describe "Basic function unit tests" -Tags Build , Unit{
        It 'Should not accept a null value for the server' {
            {Connect-UDPClient -Server $null -Port 514} | Should Throw 'The argument is null or empty'
        }

        It 'Should not accept an empty string for the server' {
            {Connect-UDPClient -Server '' -Port 514} | Should Throw 'The argument is null or empty'
        }

        It 'Should accept an IP address for the server' {
            {Connect-UDPClient -Server '127.0.0.1' -Port 514} | Should not throw
        }

        It 'Should accept an hostname string for the server' {
            {Connect-UDPClient -Server 'localhost' -Port 514} | Should not throw
        }

        It 'Should not accept a null value for the port' {
            {Connect-UDPClient -Server '127.0.0.1' -Port $null} | Should Throw 'Cannot validate argument on parameter'
        }

        It 'Should not accept an invalid value for the port' {
            {Connect-UDPClient -Server '127.0.0.1' -Port 456789789789} | Should Throw 'Error: "Value was either too large or too small for a UInt16.'
        }

        It 'creates a UDP client' {
            {Connect-UDPClient -Server '127.0.0.1' -Port 514} | should not be $null
        }
    }

}
