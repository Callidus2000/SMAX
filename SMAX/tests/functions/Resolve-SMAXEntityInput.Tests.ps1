BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..\..\SMAX.psd1'
    Import-Module $modulePath -Force

    $script:entityDescription = @{
        CurrentAssignment = [pscustomobject]@{
            name           = 'CurrentAssignment'
            logical_type   = 'ENUM'
            remoteType     = $null
            possibleValues = [pscustomobject]@{
                Incident    = 'Incident'
                ServiceDesk = 'Service Desk'
            }
        }
        AssignedToGroup = [pscustomobject]@{
            name           = 'AssignedToGroup'
            logical_type   = 'ENTITY_LINK'
            remoteType     = 'PersonGroup'
            possibleValues = $null
        }
        DisplayLabel = [pscustomobject]@{
            name           = 'DisplayLabel'
            logical_type   = 'STRING'
            remoteType     = $null
            possibleValues = $null
        }
        UserOptions = [pscustomobject]@{
            name           = 'UserOptions'
            logical_type   = 'STRING'
            remoteType     = $null
            possibleValues = $null
        }
    }
}

Describe 'Resolve-SMAXEntityInput' {
    BeforeEach {
        Mock Get-SMAXEntityDescription {
            $script:entityDescription
        } -ModuleName SMAX

        Mock Get-SMAXEntity {
            [pscustomobject]@{ Id = '1001' }
        } -ModuleName SMAX
    }

    It 'accepts a JSON string and canonicalizes property names' {
        $result = Resolve-SMAXEntityInput -InputObject '{"displaylabel":"Test"}' -EntityType Request -Connection 'test'

        $result.DisplayLabel | Should -Be 'Test'
        $result.Keys | Should -Be @('DisplayLabel')
    }

    It 'accepts a PSCustomObject and normalizes ENUM values' {
        $input = [pscustomobject]@{ CurrentAssignment = 'servicedesk' }

        $result = Resolve-SMAXEntityInput -InputObject $input -EntityType Request -Connection 'test'

        $result.CurrentAssignment | Should -Be 'ServiceDesk'
    }

    It 'accepts a hashtable through the pipeline' {
        $result = @{ DisplayLabel = 'Pipeline input' } |
            Resolve-SMAXEntityInput -EntityType Request -Connection 'test'

        $result.DisplayLabel | Should -Be 'Pipeline input'
    }

    It 'resolves root ENTITY_LINK lookups to an Id' {
        $result = Resolve-SMAXEntityInput -InputObject @{ 'lookup.AssignedToGroup' = "Name='Operations'" } -EntityType Request -Connection 'test'

        $result.AssignedToGroup | Should -Be '1001'
        Should -Invoke Get-SMAXEntity -ModuleName SMAX -Times 1 -ParameterFilter {
            $EntityType -eq 'PersonGroup' -and $Filter -eq "Name='Operations'"
        }
    }

    It 'resolves complete UserOptions lookup tokens and leaves partial tokens unchanged' {
        $input = @{
            UserOptions = '{"complexTypeProperties":[{"properties":{"Location":"{{lookup:Location|DisplayLabel=''Extended Zone''}}","Note":"prefix {{lookup:Location|DisplayLabel=''Extended Zone''}}"}}]}'
        }

        $result = Resolve-SMAXEntityInput -InputObject $input -EntityType Request -Connection 'test'
        $userOptions = $result.UserOptions | ConvertFrom-Json

        $userOptions.complexTypeProperties[0].properties.Location | Should -Be '1001'
        $userOptions.complexTypeProperties[0].properties.Note | Should -Be "prefix {{lookup:Location|DisplayLabel='Extended Zone'}}"
    }

    It 'rejects duplicate canonical properties' {
        {
            Resolve-SMAXEntityInput -InputObject @{ DisplayLabel = 'One'; 'lookup.DisplayLabel' = "Name='Two'" } -EntityType Request -Connection 'test'
        } | Should -Throw "*specified more than once*"
    }

    It 'rejects a lookup with no matching entity' {
        Mock Get-SMAXEntity { @() } -ModuleName SMAX

        {
            Resolve-SMAXEntityInput -InputObject @{ 'lookup.AssignedToGroup' = "Name='Unknown'" } -EntityType Request -Connection 'test'
        } | Should -Throw "*did not find*"
    }

    It 'rejects a lookup with multiple matching entities' {
        Mock Get-SMAXEntity {
            @([pscustomobject]@{ Id = '1001' }, [pscustomobject]@{ Id = '1002' })
        } -ModuleName SMAX

        {
            Resolve-SMAXEntityInput -InputObject @{ 'lookup.AssignedToGroup' = "Name='Duplicate'" } -EntityType Request -Connection 'test'
        } | Should -Throw "*found multiple*"
    }

    It 'rejects malformed JSON input' {
        {
            Resolve-SMAXEntityInput -InputObject '{invalid}' -EntityType Request -Connection 'test'
        } | Should -Throw '*valid JSON*'
    }
}