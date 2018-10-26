function Export-NintexWorkflowO365() {
    <#
    .SYNOPSIS
    Funktion für das exportieren eines Nintex Workflow in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflow zu exportieren.
    https://help.nintex.com/en-us/sdks/sdko365/Operational/SDK_NWO_OPS_ExportWorkflow.htm
    .PARAMETER apiKey
    APIKEY für die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL für die Nintex Office 365 API    
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
        [Parameter(Mandatory = $true)][string] $exportPath,
        [Parameter(Mandatory = $true)][Microsoft.SharePoint.Client.SharePointOnlineCredentials] $SPOCred
    )
    process
    {
        $client = New-HttpClient -apiKey $apiKey -spSiteUrl $spSiteUrl
        
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

function Import-NewNintexWorkflowO365() {
    <#
    .SYNOPSIS
    Funktion für das importieren eines neues Nintex Workflows in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflows zu importieren.
    Der Process importiert, speichert, und veröffentlicht das Formular.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#Operational/SDK_NWO_OPS_ImportNewWorkflow.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Workflow%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____2
    .PARAMETER apiKey
    APIKEY für die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL für die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listTitle
    List ID wo das Formular veröffentlicht werden soll
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
        $client = New-HttpClient -apiKey $apiKey -spSiteUrl $spSiteUrl
        
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

function Import-ExistingNintexWorkflowO365() {
    <#
    .SYNOPSIS
    Funktion für das importieren eines bestehenden Nintex Workflows in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflows zu importieren.
    Der Process importiert, speichert, und veröffentlicht das Workflow.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#Operational/SDK_NWO_OPS_ImportOldWorkflow.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Workflow%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____3
    .PARAMETER apiKey
    APIKEY für die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL für die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listTitle
    List ID wo das Workflow veröffentlicht werden soll
    .PARAMETER importPath
    Pfad wo das zu speichernde Workflows liegt
    .PARAMETER importPath
    Workflow ID wo der Workflow veröffentlicht werden soll
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
        $client = New-HttpClient -apiKey $apiKey -spSiteUrl $spSiteUrl
        
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

function Save-NintexWorkflowO365() {
    <#
    .SYNOPSIS
    Funktion für das speichern eines Nintex Workflows in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflows zu speichern.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#Operational/SDK_NWO_OPS_SaveWorkflow.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Workflow%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____4
    .PARAMETER apiKey
    APIKEY für die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL für die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listId
    List ID wo das Workflows veröffentlicht werden soll
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
        $client = New-HttpClient -apiKey $apiKey -spSiteUrl $spSiteUrl
        
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

function Publish-NintexWorkflowO365() {
    <#
    .SYNOPSIS
    Funktion für das veröffentlichen eines Nintex Workflows in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflows zu veröffentlichen.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#Operational/SDK_NWO_OPS_PublishWorkflow.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Workflow%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____5
    .PARAMETER apiKey
    APIKEY für die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL für die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER workflowId
    List ID wo das Workflows veröffentlicht werden soll
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
        $client = New-HttpClient -apiKey $apiKey -spSiteUrl $spSiteUrl
        
        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $publishWorkflowUri  = [string]::Format("{0}/api/v1/workflows/{1}/published", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($workflowId))
        $stringContent = New-Object System.Net.Http.StringContent("")
        $response = $client.PostAsync($publishWorkflowUri, $stringContent).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            Write-Host "Workflow wurde erfolgreich veröffentlicht!"
        }
        else {
            Write-Host "Fehler in der Verarbeitung des REST-API-Aufrufes!"
        }
    }
}

function Register-NintexWorkflowUseO365() {
    <#
    .SYNOPSIS
    Funktion für das zuweisen (Umgebung) eines Nintex Workflows in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Workflow zur Produktiven oder Development Umgebung zuzuweisen.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#Operational/SDK_NWO_OPS_AssignedUse.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Workflow%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____6
    .PARAMETER apiKey
    APIKEY für die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL für die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER workflowId
    Worfklow ID wo das Formular veröffentlicht werden soll
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
        $client = New-HttpClient -apiKey $apiKey -spSiteUrl $spSiteUrl
        
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

function Export-NintexFormO365() {
    <#
    .SYNOPSIS
    Funktion für das exportieren eines Nintex Forms in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Form zu exportieren.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#FormSDK/Topics/SDK_NFO_PRC_ExportForm.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Forms%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____1
    .PARAMETER apiKey
    APIKEY für die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL für die Nintex Office 365 API    
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
        $client = New-HttpClient -apiKey $apiKey -spSiteUrl $spSiteUrl
        
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

function Import-NintexFormO365() {
    <#
    .SYNOPSIS
    Funktion für das importieren eines Nintex Forms in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Formular zu importieren.
    Der Process importiert, speichert, und veröffentlicht das Formular.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#FormSDK/Topics/SDK_NFO_PRC_ImportNewForm.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Forms%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____2
    .PARAMETER apiKey
    APIKEY für die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL für die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listId
    List ID wo das Formular veröffentlicht werden soll
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
        [Parameter(Mandatory = $true)][string] $importPath,
        [Parameter(Mandatory = $true)][Microsoft.SharePoint.Client.SharePointOnlineCredentials] $SPOCred
    )
    process 
    {
        $client = New-HttpClient -apiKey $apiKey -spSiteUrl $spSiteUrl

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
            Write-Verbose "Form was successfully imported!"
        }
        else {
            Write-Host "Error while processing the REST-API call to Nintex!"
            Write-Host "$($response.ReasonPhrase)"
        }
    }
}

function Save-NintexFormO365() {
    <#
    .SYNOPSIS
    Funktion für das speichern eines Nintex Forms in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Formular zu speichern.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#FormSDK/Topics/SDK_NFO_PRC__SaveForm.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Forms%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____3
    .PARAMETER apiKey
    APIKEY für die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL für die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listId
    List ID wo das Formular veröffentlicht werden soll
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

function Publish-NintexFormO365() {
    <#
    .SYNOPSIS
    Funktion f??r das ver?¶ffentlichen eines Nintex Forms in einer Office 365 Umgebung.
    .DESCRIPTION
    Die Funktion spricht eine eigene Nintex API an um einen Formular zu ver?¶ffentlichen.
    https://help.nintex.com/en-us/sdks/sdko365/Default.htm#FormSDK/Topics/SDK_NFO_PRC_PublishForm.htm%3FTocPath%3DNintex%2520Office%2520365%2520API%7CNintex%2520Forms%2520for%2520Office%2520365%2520REST%2520API%7CGuide%7C_____4
    .PARAMETER apiKey
    APIKEY f??r die Nintex Office 365 API
    .PARAMETER apiRootUrl
    ROOT URL f??r die Nintex Office 365 API    
    .PARAMETER spSiteUrl
    URL zur SharePoint Seite
    .PARAMETER listId
    List ID wo das Formular ver?¶ffentlicht werden soll
    .EXAMPLE
    publishNintexFormO365 -apiKey "6d71f59244f74ba78875768b9c1c9ef6" -apiRootUrl "https://busitec.nintexo365.com" -spSiteUrl "https://busitec.sharepoint.com/sites/dev-stwms-onboarding" -listId "1b0fbebf-392d-4cde-8351-f24a88436459"
    #>
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $listId,
        [Parameter(Mandatory = $true)][Microsoft.SharePoint.Client.SharePointOnlineCredentials] $SPOCred
    )
    process 
    {
        $client = New-HttpClient -apiKey $apiKey -spSiteUrl $spSiteUrl

        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $publishFormUri = [string]::Format("{0}/api/v1/forms/{1}/publish", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($listId))
        $stringContent = New-Object System.Net.Http.StringContent("")
        $response = $client.PostAsync($publishFormUri, $stringContent).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            Write-Verbose "Form has been published!"
        }
        else {
            Write-Host "Error while processing the REST-API call to Nintex!"
            Write-Host "$($response.ReasonPhrase)"
        }
    }
}

function Remove-NintexFormO365(){
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $apiRootUrl,
        [Parameter(Mandatory = $true)][string] $spSiteUrl,
        [Parameter(Mandatory = $true)][string] $listId,
        [Parameter(Mandatory = $true)][string] $contentTypId,
        [Parameter(Mandatory = $true)][Microsoft.SharePoint.Client.SharePointOnlineCredentials] $SPOCred
    )
    process {
        $client = New-HttpClient -apiKey $apiKey -spSiteUrl $spSiteUrl

        #If we're at this point, we're ready to make our request.
        #Note that we're making this call synchronously - you can call the REST API
        #asynchronously, as needed.
        $deleteFormUri = [string]::Format("{0}/api/v1/forms/{1},{2}", $apiRootUrl.TrimEnd("/"), [uri]::EscapeUriString($listId), [uri]::EscapeUriString($contentTypId))
        $response = $client.DeleteAsync($deleteFormUri).Result
        #If we're successful, write an export file from the body of the response.
        if ($response.IsSuccessStatusCode -eq $true) {
            Write-Verbose "Form has been deleted!"
        }
        else {
            Write-Host "Error while processing the REST-API call to Nintex!"
            Write-Host "$($response.ReasonPhrase)"
        }        
    }
}

function New-HttpClient {
    param (
        [Parameter(Mandatory = $true)][string] $apiKey,
        [Parameter(Mandatory = $true)][string] $spSiteUrl
    )
    process {
        Add-Type -AssemblyName "System.Net.Http"
        #Step 1: create authorization tooken
        # Create a new SharePointOnlineCredentials object, using the specified credential.
        # $credential = Get-Credential
        # $SPOCred = New-Object -TypeName Microsoft.SharePoint.Client.SharePointOnlineCredentials -ArgumentList $credential.UserName, $credential.Password 
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
        return $client
    }
}
Export-ModuleMember -Function Export-NintexWorkflowO365, Import-NewNintexWorkflowO365, Import-ExistingNintexWorkflowO365, Save-NintexWorkflowO365, Publish-NintexWorkflowO365, Register-NintexWorkflowUseO365, Export-NintexFormO365, Import-NintexFormO365, Save-NintexFormO365, Publish-NintexFormO365, Remove-NintexFormO365