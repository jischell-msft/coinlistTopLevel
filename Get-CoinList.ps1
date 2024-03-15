function Get-CoinList {
    <#
.SYNOPSIS
    Generate top-level domain list from ZeroDot1's Coin Blocker Lists
.DESCRIPTION
    Starting from ZeroDot1's CoinBlockerLists repository (or similar list of 
    your choosing), create a de-duplicated set of domains that are of 'n' length, 
    as configured by the -MinLength_Domain parameter. This function is designed 
    to provide a more compact set of domains for checking  network traffic for 
    coin mining behaviors.
.NOTES
    
Name:       Get-CoinList
Author:     JiSchell
Create:     2024-03-14
Modify:     2024-03-15
Version:    0.2.0
#>


    [CmdletBinding()]
    param 
    (
        [string]
        $TargetUrl = 'https://gitlab.com/ZeroDot1/CoinBlockerLists/-/raw/master/list.txt',

        [Int16]
        [ValidateRange(4, 10)]
        $MinLength_Domain = 6
    )
    
    begin {
        $outResult = New-Object -TypeName System.Collections.ArrayList
        $listPull = (Invoke-RestMethod -Uri $TargetUrl) -split "`r?`n"
        if ($listPull.length -lt 10 ) {
            Write-Error -Message "Coin List Download Failed"
            Break
        }
    }    
    process {
        foreach ($domain in $listPull) {
            $out_domain = ""
            $sub_sections = $domain.split('.')
            $second_lvl = "$($sub_sections[-2]).$($sub_sections[-1])"
            
            if ( $second_lvl.Length -ge $MinLength_Domain -and
                $second_lvl.Length -le $domain.length) {
                $out_domain = $second_lvl
            }
            elseif ( $second_lvl.Length -lt $MinLength_Domain -and
                $domain.length -gt $MinLength_Domain -and 
                $sub_sections.count -ge 3) {
                $third_lvl = "$($sub_sections[-3]).$($second_lvl)"
                $out_domain = $third_lvl
            }
            else {
                $out_domain = $second_lvl
            }
            [void]$outResult.Add($out_domain) 
        }
    }
    end {
        $outResult = $outResult | Sort-Object -Unique
        $outResult
    }
}
