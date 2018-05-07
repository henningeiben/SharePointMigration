function export-NintexWorkflowO365() {
    <#
    .SYNOPSIS
    Funktion f�r das exportieren eines Nintex Workflow in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflow zu exportieren.
    https://help.nintex.com/en-us/sdks/sdko365/Operational/SDK_NWO_OPS_ExportWorkflow.htm
    .PARAMETER apiKey
    APIKEY f�r die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL f�r die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER sourceWorkflowId
    Workflow ID des zu exportierenen Workflows
    .PARAMETER exportPath
    Pfad wo der Workflow hingespeichert werden soll
    .EXAMPLE
    exportNintexWorkflowO365 -apiKey "6d71f59244f74ba78875768b9c1c9ef6" -apiRootUrl "https://busitec.nintexo365.com" -spSiteUrl "https://busitec.sharepoint.com/sites/dev-stwms-onboarding" -sourceWorkflowId "1b0fbebf-392d-4cde-8351-f24a88436459" -exportPath "C:\Test\Test\"
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $sourceWorkflowId,
        [Parameter(Mandatory = $true)][string] $exportPath
    )
    process
    {
        Add-Type -AssemblyName "System.Net.Http"
        #Step 1: create authorization tooken
        # Create a new SharePointOnlineCredentials object, using the specified credential.
        $credential = Get-Credential
        $SPOCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList $credential.UserName, $credential.Password 
        # Return the authentication cookie from the SharePointOnlineCredentials object, 
        # using the specified SharePoint site.
        $cookie = $SPOCred.GetAuthenticationCookie($spSiteUrl)
        #Step 2: create request
        #Create a new HTTP client and configure its base address.
        $client = New-Object System.Net.Http.HttpClient
        $client.BaseAddress = $spSiteUrl
        #Add common request headers for the REST API to the HTTP client.
        $header = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json")
        $client.DefaultRequestHeaders.Accept.Add($Header)
        $client.DefaultRequestHeaders.Add("Api-Key", $apiKey)
        #Get the SharePoint authorization cookie to be used by the HTTP client
        #for the request, and use it for the Authorization request header.
        if ($cookie) {
            $authHeader = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("cookie", [string]::Format("{0} {1}", $spSiteUrl, $cookie))
            $client.DefaultRequestHeaders.Authorization = $authHeader
        }
        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $exportWorkflowUri = [string]::Format("{0}/api/v1/workflows/packages/{1}", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($sourceWorkflowId))
        $response = $client.GetAsync($exportWorkflowUri).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            #The response body contains a Base64-encoded binary string, which we'll
            #asynchronously retrieve and then write to a new export file.
            $exportfileContent = $response.Content.ReadAsByteArrayAsync()
            [IO.File]::WriteAllBytes($exportPath, $exportfileContent.Result)
        }
        else {
            Write-Host "Fehler in der Verarbeitung des REST-API-Aufrufes!"
        }
    }
}
function importIntoNewNintexWorkflowO365() {
    <#
    .SYNOPSIS
    Funktion f�r das importieren eines neues Nintex Workflows in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflows zu importieren.
    Der Process importiert, speichert, und ver�ffentlicht das Formular.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#Operational/SDK_NWO_OPS_ImportNewWorkflow.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Workflow%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____2
    .PARAMETER apiKey
    APIKEY f�r die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL f�r die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listTitle
    List ID wo das Formular ver�ffentlicht werden soll
    .PARAMETER importPath
    Pfad wo das zu speichernde Workflows liegt
    .EXAMPLE
    importIntoNewNintexWorkflowO365 -apiKey "6d71f59244f74ba78875768b9c1c9ef6" -apiRootUrl "https://busitec.nintexo365.com" -spSiteUrl "https://busitec.sharepoint.com/sites/dev-stwms-onboarding" -listId "1b0fbebf-392d-4cde-8351-f24a88436459" -importPath "C:\Test\Test.nwf"
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $listTitle,
        [Parameter(Mandatory = $true)][string] $importPath
    )
    process 
    {
        Add-Type -AssemblyName "System.Net.Http"
        #Step 1: create authorization tooken
        # Create a new SharePointOnlineCredentials object, using the specified credential.
        $credential = Get-Credential
        $SPOCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList $credential.UserName, $credential.Password 
        # Return the authentication cookie from the SharePointOnlineCredentials object, 
        # using the specified SharePoint site.
        $cookie = $SPOCred.GetAuthenticationCookie($spSiteUrl)
        #Step 2: create request
        #Create a new HTTP client and configure its base address.
        $client = New-Object System.Net.Http.HttpClient
        $client.BaseAddress = $spSiteUrl
        #Add common request headers for the REST API to the HTTP client.
        $header = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json")
        $client.DefaultRequestHeaders.Accept.Add($Header)
        $client.DefaultRequestHeaders.Add("Api-Key", $apiKey)
        #Get the SharePoint authorization cookie to be used by the HTTP client
        #for the request, and use it for the Authorization request header.
        if ($cookie) {
            $authHeader = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("cookie", [string]::Format("{0} {1}", $spSiteUrl, $cookie))
            $client.DefaultRequestHeaders.Authorization = $authHeader
        }
        #Read the file.
        $exportFileContents = [IO.File]::ReadAllBytes($importPath)
        $saveContent = New-Object System.Net.Http.ByteArrayContent($exportFileContents, 0, $exportFileContents.Length)
         
        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $importWorkflowUri = [string]::Format("{0}/api/v1/workflows/packages/?migrate=true&listTitle={1}", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($listTitle))
        $response = $client.PostAsync($importWorkflowUri, $saveContent).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            Write-Host "Workflow wurde erfolgreich importiert!"
        }
        else {
            Write-Host "Fehler in der Verarbeitung des REST-API-Aufrufes!"
        }
    }
}
function importIntoExistingNintexWorkflowO365() {
    <#
    .SYNOPSIS
    Funktion f�r das importieren eines bestehenden Nintex Workflows in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflows zu importieren.
    Der Process importiert, speichert, und ver�ffentlicht das Workflow.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#Operational/SDK_NWO_OPS_ImportOldWorkflow.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Workflow%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____3
    .PARAMETER apiKey
    APIKEY f�r die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL f�r die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listTitle
    List ID wo das Workflow ver�ffentlicht werden soll
    .PARAMETER importPath
    Pfad wo das zu speichernde Workflows liegt
    .PARAMETER importPath
    Workflow ID wo der Workflow ver�ffentlicht werden soll
    .EXAMPLE
    importIntoExistingNintexWorkflowO365 -apiKey "6d71f59244f74ba78875768b9c1c9ef6" -apiRootUrl "https://busitec.nintexo365.com" -spSiteUrl "https://busitec.sharepoint.com/sites/dev-stwms-onboarding" -listId "1b0fbebf-392d-4cde-8351-f24a88436459" -$workflowId "1b0fbebf-392d-4cde-8351-f24a88436459" -importPath "C:\Test\Test.nwf"
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $listTitle,
        [Parameter(Mandatory = $true)][string] $importPath,
        [Parameter(Mandatory = $true)][string] $workflowId
    )
    process
    {
        Add-Type -AssemblyName "System.Net.Http"
        #Step 1: create authorization tooken
        # Create a new SharePointOnlineCredentials object, using the specified credential.
        $credential = Get-Credential
        $SPOCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList $credential.UserName, $credential.Password 
        # Return the authentication cookie from the SharePointOnlineCredentials object, 
        # using the specified SharePoint site.
        $cookie = $SPOCred.GetAuthenticationCookie($spSiteUrl)
        #Step 2: create request
        #Create a new HTTP client and configure its base address.
        $client = New-Object System.Net.Http.HttpClient
        $client.BaseAddress = $spSiteUrl
        #Add common request headers for the REST API to the HTTP client.
        $header = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json")
        $client.DefaultRequestHeaders.Accept.Add($Header)
        $client.DefaultRequestHeaders.Add("Api-Key", $apiKey)
        #Get the SharePoint authorization cookie to be used by the HTTP client
        #for the request, and use it for the Authorization request header.
        if ($cookie) {
            $authHeader = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("cookie", [string]::Format("{0} {1}", $spSiteUrl, $cookie))
            $client.DefaultRequestHeaders.Authorization = $authHeader
        }
        #Read the file.
        $exportFileContents = [IO.File]::ReadAllBytes($importPath)
        $saveContent = New-Object System.Net.Http.ByteArrayContent($exportFileContents, 0, $exportFileContents.Length)
        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $importWorkflowUri = [string]::Format("{0}/api/v1/workflows/packages/{1}?migrate=true&listTitle={2}", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($workflowId), [uri]::EscapeUriString($listTitle))
        $response = $client.PutAsync($importWorkflowUri, $saveContent).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            Write-Host "Workflow wurde erfolgreich importiert!"
        }
        else {
            Write-Host "Fehler in der Verarbeitung des REST-API-Aufrufes!"
        }
    }
}
function saveNintexWorkflowO365() {
    <#
    .SYNOPSIS
    Funktion f�r das speichern eines Nintex Workflows in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflows zu speichern.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#Operational/SDK_NWO_OPS_SaveWorkflow.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Workflow%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____4
    .PARAMETER apiKey
    APIKEY f�r die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL f�r die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listId
    List ID wo das Workflows ver�ffentlicht werden soll
    .PARAMETER workflowId
    Pfad wo das zu speichernde Workflows liegt
    .EXAMPLE
    saveNintexWorkflowO365 -apiKey "6d71f59244f74ba78875768b9c1c9ef6" -apiRootUrl "https://busitec.nintexo365.com" -spSiteUrl "https://busitec.sharepoint.com/sites/dev-stwms-onboarding" -workflowId "1b0fbebf-392d-4cde-8351-f24a88436459" -importPath "C:\Test\Test.nwf"
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $workflowId,
        [Parameter(Mandatory = $true)][string] $importPath
    )
    process 
    {
        Add-Type -AssemblyName "System.Net.Http"
        #Step 1: create authorization tooken
        # Create a new SharePointOnlineCredentials object, using the specified credential.
        $credential = Get-Credential
        $SPOCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList $credential.UserName, $credential.Password 
        # Return the authentication cookie from the SharePointOnlineCredentials object, 
        # using the specified SharePoint site.
        $cookie = $SPOCred.GetAuthenticationCookie($spSiteUrl)
        #Step 2: create request
        #Create a new HTTP client and configure its base address.
        $client = New-Object System.Net.Http.HttpClient
        $client.BaseAddress = $spSiteUrl
        #Add common request headers for the REST API to the HTTP client.
        $header = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json")
        $client.DefaultRequestHeaders.Accept.Add($Header)
        $client.DefaultRequestHeaders.Add("Api-Key", $apiKey)
        #Get the SharePoint authorization cookie to be used by the HTTP client
        #for the request, and use it for the Authorization request header.
        if ($cookie) {
            $authHeader = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("cookie", [string]::Format("{0} {1}", $spSiteUrl, $cookie))
            $client.DefaultRequestHeaders.Authorization = $authHeader
        }
        #Read the file.
        $exportFileContents = [IO.File]::ReadAllBytes($importPath);
        $saveContent = New-Object System.Net.Http.ByteArrayContent -ArgumentList @(,$exportFileContents)
        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $saveWorkflowUri = [string]::Format("{0}/api/v1/workflows/{1}", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($workflowId))
        $response = $client.PutAsync($saveWorkflowUri, $saveContent).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            Write-Host "Workflow wurde erfolgreich gespeichert!"
        }
        else {
            Write-Host "Fehler in der Verarbeitung des REST-API-Aufrufes!"
        }
    }
}
function publishNintexWorkflowO365() {
    <#
    .SYNOPSIS
    Funktion f�r das ver�ffentlichen eines Nintex Workflows in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflows zu ver�ffentlichen.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#Operational/SDK_NWO_OPS_PublishWorkflow.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Workflow%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____5
    .PARAMETER apiKey
    APIKEY f�r die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL f�r die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER workflowId
    List ID wo das Workflows ver�ffentlicht werden soll
    .EXAMPLE
    publishNintexWorkflowO365 -apiKey "6d71f59244f74ba78875768b9c1c9ef6" -apiRootUrl "https://busitec.nintexo365.com" -spSiteUrl "https://busitec.sharepoint.com/sites/dev-stwms-onboarding" -workflowId "1b0fbebf-392d-4cde-8351-f24a88436459"
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $workflowId
    )
    process 
    {
        Add-Type -AssemblyName "System.Net.Http"
        #Step 1: create authorization tooken
        # Create a new SharePointOnlineCredentials object, using the specified credential.
        $credential = Get-Credential
        $SPOCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList $credential.UserName, $credential.Password 
        # Return the authentication cookie from the SharePointOnlineCredentials object, 
        # using the specified SharePoint site.
        $cookie = $SPOCred.GetAuthenticationCookie($spSiteUrl)
        #Step 2: create request
        #Create a new HTTP client and configure its base address.
        $client = New-Object System.Net.Http.HttpClient
        $client.BaseAddress = $spSiteUrl
        #Add common request headers for the REST API to the HTTP client.
        $header = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json")
        $client.DefaultRequestHeaders.Accept.Add($Header)
        $client.DefaultRequestHeaders.Add("Api-Key", $apiKey)
        #Get the SharePoint authorization cookie to be used by the HTTP client
        #for the request, and use it for the Authorization request header.
        if ($cookie) {
            $authHeader = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("cookie", [string]::Format("{0} {1}", $spSiteUrl, $cookie))
            $client.DefaultRequestHeaders.Authorization = $authHeader
        }
        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $publishWorkflowUri  = [string]::Format("{0}/api/v1/workflows/{1}/published", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($workflowId))
        $stringContent = New-Object System.Net.Http.StringContent("")
        $response = $client.PostAsync($publishWorkflowUri, $stringContent).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            Write-Host "Workflow wurde erfolgreich ver�ffentlicht!"
        }
        else {
            Write-Host "Fehler in der Verarbeitung des REST-API-Aufrufes!"
        }
    }
}
function assignNintexWorkflowUseO365() {
    <#
    .SYNOPSIS
    Funktion f�r das zuweisen (Umgebung) eines Nintex Workflows in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflow zur Produktiven oder Development Umgebung zuzuweisen.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#Operational/SDK_NWO_OPS_AssignedUse.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Workflow%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____6
    .PARAMETER apiKey
    APIKEY f�r die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL f�r die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER workflowId
    Worfklow ID wo das Formular ver�ffentlicht werden soll
    .PARAMETER assigned
    Umgebung wo der Worklflow zugewiesen soll Production oder Development
    .EXAMPLE
    assignNintexWorkflowUseO365 -apiKey "6d71f59244f74ba78875768b9c1c9ef6" -apiRootUrl "https://busitec.nintexo365.com" -spSiteUrl "https://busitec.sharepoint.com/sites/dev-stwms-onboarding" -workflowId "1b0fbebf-392d-4cde-8351-f24a88436459" -assigned "Production"
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $workflowId,
        [Parameter(Mandatory = $true)][string] $assigned
    )
    process 
    {
        Add-Type -AssemblyName "System.Net.Http"
        #Step 1: create authorization tooken
        # Create a new SharePointOnlineCredentials object, using the specified credential.
        $credential = Get-Credential
        $SPOCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList $credential.UserName, $credential.Password 
        # Return the authentication cookie from the SharePointOnlineCredentials object, 
        # using the specified SharePoint site.
        $cookie = $SPOCred.GetAuthenticationCookie($spSiteUrl)
        #Step 2: create request
        #Create a new HTTP client and configure its base address.
        $client = New-Object System.Net.Http.HttpClient
        $client.BaseAddress = $spSiteUrl
        #Add common request headers for the REST API to the HTTP client.
        $header = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json")
        $client.DefaultRequestHeaders.Accept.Add($Header)
        $client.DefaultRequestHeaders.Add("Api-Key", $apiKey)
        #Get the SharePoint authorization cookie to be used by the HTTP client
        #for the request, and use it for the Authorization request header.
        if ($cookie) {
            $authHeader = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("cookie", [string]::Format("{0} {1}", $spSiteUrl, $cookie))
            $client.DefaultRequestHeaders.Authorization = $authHeader
        }
        #The requestbody
        $requestBody ="{\value\: \"+ $assigned + "\}"
        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $assignWorkflowUseUri = [string]::Format("{0}/api/v1/workflows/{1}/assigneduse", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($workflowId))
        $response = $client.PutAsync($assignWorkflowUseUri, $requestBody).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            Write-Host "Form wurde erfolgreich dem Bereich" + $assigned + "zugewiesen"
        }
        else {
            Write-Host "Fehler in der Verarbeitung des REST-API-Aufrufes!"
        }
    }
}
function exportNintexFormO365() {
    <#
    .SYNOPSIS
    Funktion f�r das exportieren eines Nintex Forms in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Form zu exportieren.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#FormSDK/Topics/SDK_NFO_PRC_ExportForm.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Forms%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____1
    .PARAMETER apiKey
    APIKEY f�r die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL f�r die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listId
    Form ID des zu exportierenen Form
    .PARAMETER exportPath
    Pfad wo der Form hingespeichert werden soll 
    .EXAMPLE
    exportNintexFormO365 -apiKey "6d71f59244f74ba78875768b9c1c9ef6" -apiRootUrl "https://busitec.nintexo365.com" -spSiteUrl "https://busitec.sharepoint.com/sites/dev-stwms-onboarding" -sourceFormId "1b0fbebf-392d-4cde-8351-f24a88436459" -exportPath "C:\Test\Test\"
    #>

    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $listId,
        [Parameter(Mandatory = $true)][string] $exportPath
    )
    process 
    {
        Add-Type -AssemblyName "System.Net.Http"
        #Step 1: create authorization tooken
        # Create a new SharePointOnlineCredentials object, using the specified credential.
        $credential = Get-Credential
        $SPOCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList $credential.UserName, $credential.Password 
        # Return the authentication cookie from the SharePointOnlineCredentials object, 
        # using the specified SharePoint site.
        $cookie = $SPOCred.GetAuthenticationCookie($spSiteUrl)
        #Step 2: create request
        #Create a new HTTP client and configure its base address.
        $client = New-Object System.Net.Http.HttpClient
        $client.BaseAddress = $spSiteUrl
        #Add common request headers for the REST API to the HTTP client.
        $client.DefaultRequestHeaders.Add("Api-Key", $apiKey)
        #Get the SharePoint authorization cookie to be used by the HTTP client
        #for the request, and use it for the Authorization request header.
        if ($cookie) {
            $authHeader = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("cookie", [string]::Format("{0} {1}", $spSiteUrl, $cookie))
            $client.DefaultRequestHeaders.Authorization = $authHeader
        }
        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $exportFormUri = [string]::Format("{0}/api/v1/forms/{1}", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($listId))
        $response = $client.GetAsync($exportFormUri).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            #The response body contains a Base64-encoded binary string, which we'll
            #asynchronously retrieve and then write to a new export file.
            $exportfileContent = $response.Content.ReadAsByteArrayAsync()
            [IO.File]::WriteAllBytes($exportPath, $exportfileContent.Result)
        }
        else {
            Write-Host "Fehler in der Verarbeitung des REST-API-Aufrufes!"
        }
    }
}
function importNintexFormO365() {
    <#
    .SYNOPSIS
    Funktion f�r das importieren eines Nintex Forms in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Formular zu importieren.
    Der Process importiert, speichert, und ver�ffentlicht das Formular.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#FormSDK/Topics/SDK_NFO_PRC_ImportNewForm.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Forms%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____2
    .PARAMETER apiKey
    APIKEY f�r die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL f�r die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listId
    List ID wo das Formular ver�ffentlicht werden soll
    .PARAMETER importPath
    Pfad wo das zu speichernde Form liegt
    .EXAMPLE
    importNintexFormO365 -apiKey "6d71f59244f74ba78875768b9c1c9ef6" -apiRootUrl "https://busitec.nintexo365.com" -spSiteUrl "https://busitec.sharepoint.com/sites/dev-stwms-onboarding" -listId "1b0fbebf-392d-4cde-8351-f24a88436459" -importPath "C:\Test\Test.nwf"
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $listId,
        [Parameter(Mandatory = $true)][string] $importPath
    )
    process 
    {
        Add-Type -AssemblyName "System.Net.Http"
        #Step 1: create authorization tooken
        # Create a new SharePointOnlineCredentials object, using the specified credential.
        $credential = Get-Credential
        $SPOCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList $credential.UserName, $credential.Password 
        # Return the authentication cookie from the SharePointOnlineCredentials object, 
        # using the specified SharePoint site.
        $cookie = $SPOCred.GetAuthenticationCookie($spSiteUrl)
        #Step 2: create request
        #Create a new HTTP client and configure its base address.
        $client = New-Object System.Net.Http.HttpClient
        $client.BaseAddress = $spSiteUrl
        #Add common request headers for the REST API to the HTTP client.
        $header = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json")
        $client.DefaultRequestHeaders.Accept.Add($Header)
        $client.DefaultRequestHeaders.Add("Api-Key", $apiKey)
        #Get the SharePoint authorization cookie to be used by the HTTP client
        #for the request, and use it for the Authorization request header.
        if ($cookie) {
            $authHeader = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("cookie", [string]::Format("{0} {1}", $spSiteUrl, $cookie))
            $client.DefaultRequestHeaders.Authorization = $authHeader
        }
        #Read the file.
        $exportFileContents = [IO.File]::ReadAllBytes($importPath);
        $saveContent = New-Object System.Net.Http.ByteArrayContent($exportFileContents, 0, $exportFileContents.Length)
        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $importFormUri = [string]::Format("{0}/api/v1/forms/{1}", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($listId))
        $response = $client.PutAsync($importFormUri, $saveContent).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            Write-Host "Form wurde erfolgreich importiert!"
        }
        else {
            Write-Host "Fehler in der Verarbeitung des REST-API-Aufrufes!"
        }
    }
}
function saveNintexFormO365() {
    <#
    .SYNOPSIS
    Funktion f�r das speichern eines Nintex Forms in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Formular zu speichern.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#FormSDK/Topics/SDK_NFO_PRC__SaveForm.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Forms%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____3
    .PARAMETER apiKey
    APIKEY f�r die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL f�r die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listId
    List ID wo das Formular ver�ffentlicht werden soll
    .PARAMETER importPath
    Pfad wo das zu speichernde Form liegt
    .EXAMPLE
    saveNintexFormO365 -apiKey "6d71f59244f74ba78875768b9c1c9ef6" -apiRootUrl "https://busitec.nintexo365.com" -spSiteUrl "https://busitec.sharepoint.com/sites/dev-stwms-onboarding" -listId "1b0fbebf-392d-4cde-8351-f24a88436459" -importPath "C:\Test\Test.nwf"
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $listId,
        [Parameter(Mandatory = $true)][string] $importPath
    )
    process
    {
        Add-Type -AssemblyName "System.Net.Http"
        #Step 1: create authorization tooken
        # Create a new SharePointOnlineCredentials object, using the specified credential.
        $credential = Get-Credential
        $SPOCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList $credential.UserName, $credential.Password 
        # Return the authentication cookie from the SharePointOnlineCredentials object, 
        # using the specified SharePoint site.
        $cookie = $SPOCred.GetAuthenticationCookie($spSiteUrl)
        #Step 2: create request
        #Create a new HTTP client and configure its base address.
        $client = New-Object System.Net.Http.HttpClient
        $client.BaseAddress = $spSiteUrl
        #Add common request headers for the REST API to the HTTP client.
        $header = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json")
        $client.DefaultRequestHeaders.Accept.Add($Header)
        $client.DefaultRequestHeaders.Add("Api-Key", $apiKey)
        #Get the SharePoint authorization cookie to be used by the HTTP client
        #for the request, and use it for the Authorization request header.
        if ($cookie) {
            $authHeader = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("cookie", [string]::Format("{0} {1}", $spSiteUrl, $cookie))
            $client.DefaultRequestHeaders.Authorization = $authHeader
        }
        #Read the file.
        $exportFileContents = [IO.File]::ReadAllBytes($importPath);
        $saveContent = New-Object System.Net.Http.ByteArrayContent($exportFileContents, 0, $exportFileContents.Length)
        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $saveFormUri = [string]::Format("{0}/api/v1/forms/{1}", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($listId))
        $response = $client.PutAsync($saveFormUri, $saveContent).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            Write-Host "Form wurde erfolgreich gespeichert!"
        }
        else {
            Write-Host "Fehler in der Verarbeitung des REST-API-Aufrufes!"
        }
    }
}
function publishNintexFormO365() {
    <#
    .SYNOPSIS
    Funktion f�r das ver�ffentlichen eines Nintex Forms in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Formular zu ver�ffentlichen.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#FormSDK/Topics/SDK_NFO_PRC_PublishForm.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Forms%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____4
    .PARAMETER apiKey
    APIKEY f�r die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL f�r die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listId
    List ID wo das Formular ver�ffentlicht werden soll
    .EXAMPLE
    publishNintexFormO365 -apiKey "6d71f59244f74ba78875768b9c1c9ef6" -apiRootUrl "https://busitec.nintexo365.com" -spSiteUrl "https://busitec.sharepoint.com/sites/dev-stwms-onboarding" -listId "1b0fbebf-392d-4cde-8351-f24a88436459"
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $listId
    )
    process 
    {
        Add-Type -AssemblyName "System.Net.Http"
        #Step 1: create authorization tooken
        # Create a new SharePointOnlineCredentials object, using the specified credential.
        $credential = Get-Credential
        $SPOCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList $credential.UserName, $credential.Password 
        # Return the authentication cookie from the SharePointOnlineCredentials object, 
        # using the specified SharePoint site.
        $cookie = $SPOCred.GetAuthenticationCookie($spSiteUrl)
        #Step 2: create request
        #Create a new HTTP client and configure its base address.
        $client = New-Object System.Net.Http.HttpClient
        $client.BaseAddress = $spSiteUrl
        #Add common request headers for the REST API to the HTTP client.
        $header = New-Object System.Net.Http.Headers.MediaTypeWithQualityHeaderValue("application/json")
        $client.DefaultRequestHeaders.Accept.Add($Header)
        $client.DefaultRequestHeaders.Add("Api-Key", $apiKey)
        #Get the SharePoint authorization cookie to be used by the HTTP client
        #for the request, and use it for the Authorization request header.
        if ($cookie) {
            $authHeader = New-Object System.Net.Http.Headers.AuthenticationHeaderValue("cookie", [string]::Format("{0} {1}", $spSiteUrl, $cookie))
            $client.DefaultRequestHeaders.Authorization = $authHeader
        }
        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $publishFormUri = [string]::Format("{0}/api/v1/forms/{1}/publish", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($listId))
        $stringContent = New-Object System.Net.Http.StringContent("")
        $response = $client.PostAsync($publishFormUri, $stringContent).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            Write-Host "Form wurde erfolgreich ver�ffentlicht!"
        }
        else {
            Write-Host "Fehler in der Verarbeitung des REST-API-Aufrufes!"
        }
    }
}
function getNintexFormDigestOnPremise {
    [CmdletBinding()]
    param (
        [string] $url
    )
    process {
        $formDigestRequest = "$url/_api/contextinfo"

        $formDigestUri = New-Object System.Uri($formDigestRequest)

        $credCache = New-Object System.Net.CredentialCache
        $credCache.Add($formDigestUri, "NTLM", [System.Net.CredentialCache]::DefaultNetworkCredentials)
        $spRequest = [System.Net.HttpWebRequest] [System.Net.HttpWebRequest]::Create($formDigestRequest)
        $spRequest.Credentials = $credCache
        $spRequest.Method = "POST"
        $spRequest.Accept = "application/json;odata=verbose"
        $spRequest.ContentLength = 0

        [System.Net.HttpWebResponse] $endpointResponse = [System.Net.HttpWebResponse] $spRequest.GetResponse()
        [System.IO.Stream]$postStream = $endpointResponse.GetResponseStream()
        [System.IO.StreamReader] $postReader = New-Object System.IO.StreamReader($postStream)
        $results = $postReader.ReadToEnd()

        $postReader.Close()
        $postStream.Close()

        #Get the FormDigest Value
        $startTag = "FormDigestValue"
        $endTag = "LibraryVersion"
        $startTagIndex = $results.IndexOf($startTag) + 1
        $endTagIndex = $results.IndexOf($endTag, $startTagIndex)
        [string] $newFormDigest = $null
        if (($startTagIndex -ge 0) -and ($endTagIndex -gt $startTagIndex)) {
            $newFormDigest = $results.Substring($startTagIndex + $startTag.Length + 2, $endTagIndex - $startTagIndex - $startTag.Length - 5)
        }

        return $newFormDigest
    }
}
function addNintexFormOnPremise {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string] $webUrl, 
        [parameter(Mandatory = $true)]
        [string] $fileName, 
        [parameter(Mandatory = $true)]
        [string] $listName
    )
    process {
        $ntxFormEndpoint = "$webUrl/_vti_bin/NintexFormsServices/NfRestService.svc/PublishFormXml"
        $formDigest = Get-FormDigest $webUrl

        $form = Get-Content $fileName #-Encoding Unicode
        $form = $form -replace '"', '\"'

        [System.Net.HttpWebRequest] $request = [System.Net.WebRequest]::Create($ntxFormEndpoint)
        $request.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
        $request.Method = "POST";
        $request.ContentType = "application/json; charset=utf-8";
        $request.Headers.Add("X-RequestDigest", $formDigest); 

        $data = "{`"listId`": `"$listName`", `"formXml`": `"$form`" }"
        $utf8 = New-Object System.Text.UTF8Encoding 
        [byte[]] $byteData = $utf8.GetBytes($data.ToString())
        $request.ContentLength = $byteData.Length;

        try {
            $postStream = $request.GetRequestStream()
            $postStream.Write($byteData, 0, $byteData.Length);
        }
        finally {
            if ($postStream) { $postStream.Dispose() }
        }

        try {
            [System.Net.HttpWebResponse] $response = [System.Net.HttpWebResponse] $request.GetResponse()

            # Get the response stream 
            [System.IO.StreamReader] $reader = New-Object System.IO.StreamReader($response.GetResponseStream())

            try {
                $strResult = $reader.ReadToEnd()
                $jsonResult = ConvertFrom-Json $strResult

            }
            catch [Exception] {

            }
        }
        finally {
            if ($response) { $response.Dispose() }
        }
    }
}
function removeNintexWorkflowOnPremise() {
    $ntxWfEndpoint = "$webUrl/_vti_bin/nintexworkflow/workflow.asmx"

    $proxy = New-WebServiceProxy -Uri $ntxWfEndpoint -UseDefaultCredential
    $proxy.URL = $ntxWfEndpoint    
    $proxy.PublishFromNWFXml($NWFContent, $listName, $workflowName, $true)
}