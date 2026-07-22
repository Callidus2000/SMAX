BeforeAll {
    $modulePath = Join-Path $PSScriptRoot '..\..\SMAX.psd1'
    Import-Module $modulePath -Force

    $script:entityDefinitions = @{
        Request = [pscustomobject]@{
            properties   = @()
            associations = @(
                [pscustomobject]@{
                    name           = 'FollowedByUsers'
                    locname        = 'Followers'
                    cardinality    = 'many'
                    linkEntityName = 'Person'
                }
            )
        }
    }
}

Describe 'Get-SMAXEntityDescription' {
    BeforeEach {
        Mock Get-SMAXConfPrefix { 'SMAX.Test' } -ModuleName SMAX
        Mock Get-PSFConfigValue { $script:entityDefinitions } -ModuleName SMAX
    }

    It 'returns associations by canonical name with their remote entity type' {
        $result = Get-SMAXEntityDescription -Connection 'test' -EntityType Request -Mode AssociationsAsHashtable

        $result['FollowedByUsers'].name | Should -Be 'FollowedByUsers'
        $result['FollowedByUsers'].remoteType | Should -Be 'Person'
    }
}