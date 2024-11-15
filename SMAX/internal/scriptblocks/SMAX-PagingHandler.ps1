Set-PSFScriptblock -Name 'SMAX.PagingHandler' -Scriptblock {
    # $EnablePaging -eq $true
    $logTagName = "SMAX.PagingHandler"
    Write-PSFMessage "Start SMAX.PagingHandler" -FunctionName 'SMAX.PagingHandler'
    try {
        if (-not ($result.meta)) {
            Write-PSFMessage "Paging enabled, but no meta.total_count result" -Level Warning -FunctionName $logTagName
        }
        else {
            $totalCount = $result.meta.total_count
            Write-PSFMessage "Paging enabled, starting loop, totalCount=$totalCount" -ModuleName ServiceManagementX -FunctionName 'SMAX.PagingHandler'
            $allItems = $result.entities
            $resultCount = ($result.entities | Measure-Object).count
            $allItemsCount = ($allItems | Measure-Object).count
            write-psfmessage "Current Item-Count: $allItemsCount" -ModuleName ServiceManagementX -FunctionName 'SMAX.PagingHandler'
            # If no Page was given as a parameter then the returned object count as the configured size
            if (!($UrlParameter.size)) {
                $UrlParameter.size = $resultCount
            }
            # If no Page was given as a parameter then it was page 1 we just requested
            if (!($UrlParameter.skip)) {
                $UrlParameter.skip = 0
            }

            while ($totalCount -gt $allItems.count -and $result.meta.completion_status -eq 'OK') {
                # Fetch the next page of items
                $UrlParameter.skip = $allItems.count
                Write-PSFMessage "totalCount=$totalCount -gt allItems.count=$($allItems.count)"  -ModuleName ServiceManagementX -FunctionName 'SMAX.PagingHandler'
                $nextParameter = @{
                    Connection          = $Connection
                    Path                = $Path
                    Body                = $Body
                    UrlParameter        = $UrlParameter
                    Method              = $Method
                    LoggingAction       = "Paging"
                    LoggingActionValues = @($allItems.count,$totalCount)
                    # NO EnablePaging in the next Call
                }
                write-psfmessage "InvokeAPI with Params= $($nextParameter|ConvertTo-Json -WarningAction SilentlyContinue -depth 10)" -Level Debug -ModuleName ServiceManagementX -FunctionName 'SMAX.PagingHandler'
                $result = Invoke-SMAXAPI @nextParameter
                $allItems += ($result.entities)
            }
            if ($result.meta.completion_status -ne 'OK') {
                Write-PSFMessage -Level Warning "completion_status NOT OK, $($result.meta |ConvertTo-Json -WarningAction SilentlyContinue -Compress)"
            }
            return $allItems
        }
    }
    catch {
        Write-PSFMessage "$_" -ErrorRecord $_ -Tag "Catch"
    }
}