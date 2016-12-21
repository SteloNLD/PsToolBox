cls
$routes = @{    
    "/ola" = {return '<html><body>Hello world!</body></html>' }
    "/exit" = {exit }
}


$Controllers = Get-Item ".\Controllers\*Controller.ps1"
Foreach ($Controller in $Controllers)
{  
    $routes.Add("/"+ ($Controller.BaseName).replace("Controller",""), $Controller.BaseName)
    ."$($Controller.FullName)"
}
    
function Load-Packages 
{
    param ([string] $directory = 'Packages')
    $assemblies = Get-ChildItem $directory -Recurse -Filter '*.dll' | Select -Expand FullName
    foreach ($assembly in $assemblies) { [System.Reflection.Assembly]::LoadFrom($assembly) }
}

Load-Packages



$url = 'http://localhost:3338/'
$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)

#Local Usage
$listener.AuthenticationSchemes = [System.Net.AuthenticationSchemes]::IntegratedWindowsAuthentication

#Domain Usage
#$listener.AuthenticationSchemes = [System.Net.AuthenticationSchemes]::Digest

$listener.Start()
Write-Host "Listening at $url..."

while ($listener.IsListening)
{
    #Get Context wich is the Request and some preprocessing from the server such as the authentication.
    $context = $listener.GetContext()
    $requestUrl = $context.Request.Url
    $response = $context.Response

    #Debug
    Write-Host ''
    Write-Host "> $requestUrl"
    Write-Host ("Segments: "+$requestUrl.Segments)    
    ($requestUrl.LocalPath).ToString()


    #Get route,
    $route = $routes.Get_Item($requestUrl.LocalPath)    
     

    #Users should be authenticated.
    if (!$context.User.Identity.IsAuthenticated) {       
        Write-Warning "Rejected request as user was not authenticated"             
        $response.StatusCode = 403
        $buffer = [System.Text.Encoding]::UTF8.GetBytes("Unauthorized")
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)                      
    }   
    
    #/Content URLs wil be proccesed normaly.   
    elseif ((($requestUrl.LocalPath).ToString()) -like '/Content*')
    {
        #Debug    
        $identity = $context.User.Identity
        "Received request $(get-date) from $($identity.Name):"
        
        #IE needs this, chrome wil warm you if not suplied.
        if ((($requestUrl.LocalPath).ToString()) -like '*.css')
        {
            $response.ContentType = "text/css"
        }
        
        #Get filecontents and send it back.
        $content = Get-Content ("." + ((($requestUrl.LocalPath).ToString())))
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)        
    }
    #No Route? No /Content? then 404 Page not Found
    elseif ($route -eq $null)
    {
        #Debug
        $identity = $context.User.Identity
        "Received request $(get-date) from $($identity.Name):"
        
        $response.StatusCode = 404
    }
    else
    {
        #Debug
        $identity = $context.User.Identity
        "Received request $(get-date) from $($identity.Name):"
        
        #Execute the Route! and send the result back.
        $content = & $route
        $buffer = [System.Text.Encoding]::UTF8.GetBytes($content)
        $response.ContentLength64 = $buffer.Length
        $response.OutputStream.Write($buffer, 0, $buffer.Length)
    }
    
    #Close/Send the repsonse
    $response.Close()

    #Debug
    $responseStatus = $response.StatusCode
    Write-Host "< $responseStatus"
}


