function Get-FormDigest {
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

function Add-NintexForm {
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

function Publish-NintexWorkflow {
    [CmdletBinding()]
    param (
        [parameter(Mandatory = $true)]
        [string] $webUrl, 
        [parameter(Mandatory = $true)]
        [string] $fileName,
        [parameter(Mandatory = $true)]
        [string] $listName,
        [parameter(Mandatory = $true)]
        [string] $workflowName
    )
    process {
        $ntxWfEndpoint = "$webUrl/_vti_bin/nintexworkflow/workflow.asmx"

        $proxy = New-WebServiceProxy -Uri $ntxWfEndpoint -UseDefaultCredential
        $proxy.URL = $ntxWfEndpoint

        $proxy.CookieContainer
        if ($proxy.CookieContainer -eq $null) {  
            $proxy.CookieContainer = New-Object System.Net.CookieContainer
        }
        
        $tmaa = New-Object System.Net.Cookie("NSC_TMAA", "58e87db01b5615163b357b34ba46e3c5", "/", "sharepoint.stadtwerke-muenster.de")
        $proxy.CookieContainer.Add($tmaa)
        $tmas = New-Object System.Net.Cookie("NSC_TMAS", "f432a083edc3f70f6e651b51d69c3757", "/", "sharepoint.stadtwerke-muenster.de")
        $proxy.CookieContainer.Add($tmas)
        $pers = New-Object System.Net.Cookie("NSC_PERS", "bee9321a17b683dc5a1fbdbcecad8ef4", "/", "sharepoint.stadtwerke-muenster.de")
        $proxy.CookieContainer.Add($pers)

    
        $NWFContent = Get-Content $fileName -Encoding "UTF8"
        $proxy.PublishFromNWFXml($NWFContent, $listName, $workflowName, $true)
    }
}

function Remove-NintexWorkflow() {
    $ntxWfEndpoint = "$webUrl/_vti_bin/nintexworkflow/workflow.asmx"

    $proxy = New-WebServiceProxy -Uri $ntxWfEndpoint -UseDefaultCredential
    $proxy.URL = $ntxWfEndpoint    
    $proxy.PublishFromNWFXml($NWFContent, $listName, $workflowName, $true)
}

Export-ModuleMember -Function Add-NintexForm, Publish-NintexWorkflow