Function ReportsController ($Action, $Params)
{       
    $ViewData = @{}
    
    #.css Files
    $ViewData.CSS = @()   
    $Files = Get-Item .\Content\Css\*.css
    $Files | % {
        $ViewData.CSS += ('<link rel="stylesheet" type="text/css" href="'+ $($_ | Resolve-Path -Relative) + '">')
    }

    #.js Files
    $ViewData.JS = @()   
    $Files = Get-Item .\Content\js\*.js
    $Files | % {
        $ViewData.JS += ('<script src="' + $($_ | Resolve-Path -Relative) + '"></script>')
    }

    Function Get-PrinterHealth ()
    {      
        $ViewData.Title = "Report-PrinterHealth"
    
        $Header = iex ('@"
' + $(get-content .\Views\Shared\Layout-header.pshtml) + '
"@')

        $LeftNav = iex ('@"
' + $(get-content .\Views\Reports\Shared\leftNav.pshtml) + '
"@')

        $Body = iex ('@"
' + $(Get-Content .\Views\Reports\Report-PrinterHealth.pshtml) + '
"@')

        $Footer = iex ('@"
' + $(Get-Content .\Views\Shared\Layout-footer.pshtml) + '
"@')
        Return ($Header + $LeftNav + $Body + $Footer)  
    }

    Return Get-PrinterHealth 
}