#	Copyright (c) 2018 SIOS Technology Corp.
#	Test-IQCredentials.ps1 
#
#	Exit codes:
#	0 - SUCCESS
#	1 - FAILURE to reach host
#	2 - FAILURE to authenticate with host
#	>2- FAILURE to authenticate with host / HTTP request failure code (i.e. 401, 404, etc)
##############################################################################################

[CmdletBinding()]
Param(
	[Parameter(Mandatory=$True, Position=0)]
	[string] $IQHostname,

	[Parameter(Mandatory=$True, Position=1)]
	[string] $IQUsername,

	[Parameter(Mandatory=$True, Position=2)]
	[string] $IQPassword
)

# start logging
$ErrorActionPreference="SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -Path "$env:temp\Test-IQCredentials.log" -append

Try {
	# required so that self-signed pages can be retrieved using Invoke-WebRequest
	add-type @"
		using System.Net;
		using System.Security.Cryptography.X509Certificates;
		public class TrustAllCertsPolicy : ICertificatePolicy {
			public bool CheckValidationResult(
				ServicePoint srvPoint, X509Certificate certificate,
				WebRequest request, int certificateProblem
			) {
				return true;
			}
		}
"@

	# required so that TLS mismatch does not cause a failure
	[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
	[System.Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
} Catch {
	Write-Verbose "Policies already exist, not adding them again."
}

Try {
	$result = Invoke-WebRequest -Uri "https://$IQHostname/api/sios/stc/cldo/version"

	# $result should contain an HTTP response at this point. The StatusCode property 
	# corresponds to the an HTTP Status Code as defined in RFC 2616. Status Code 200
	# is "OK". Return any other status as an error code.
	if( $result.StatusCode -NotLike "200" ) {
		# stop logging
		Stop-Transcript
		exit $result.StatusCode
	}
} Catch {
	# If we caught an error and the message contains an HTTP Status Code, then we return that
	# as an error code.
	if($m = $_ | Select-String -Pattern ".*HTTP Status (\d+).*"){
		Write-Verbose $_
		# stop logging
		Stop-Transcript
		exit $m.Matches.Groups[1].Value
	}

	# If the cmdlet failed, and does not contain an HTTP Status Code, we likely cannot reach
	# the designated host.
	Write-Verbose $_
	# stop logging
	Stop-Transcript
	exit 1
}

# create and encode message header because Invoke-WebRequest can't figure it out otherwise  
$creds = "$($IQUsername):$($IQPassword)"
$encodedCreds = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($creds))
$basicAuthValue = "Basic $encodedCreds"
$Headers = @{
	Authorization = $basicAuthValue
}

# verify credentials
Try {
	$result = Invoke-WebRequest -Uri "https://$IQHostname/api/sios/stc/cldo/environment" -Headers $Headers

	# This is for backup really, and won't usually run as any error status will be handled in the Catch 
	# block below. In case there is some way for Invoke-WebRequest to 'succeed' without actually 
	# succeeding, then the code here will function the same as the code in the Catch block. I.e. it will 
	# return the HTTP Status as an error code.
	if( $result.StatusCode -NotLike "200" ) {
		# stop logging
		Stop-Transcript
		exit $result.StatusCode
	}
} Catch {
	# If we caught an error and the message contains an HTTP Status Code, then we return that
	# as an error code.
	if($m = $_ | Select-String -Pattern ".*HTTP Status (\d+).*"){
		Write-Verbose $_
		# stop logging
		Stop-Transcript
		exit $m.Matches.Groups[1].Value
	}

	# If the cmdlet failed, and does not contain an HTTP Status Code (and we got this far), we are 
	# likely failing authentication with the host.
	Write-Verbose $_
	# stop logging
	Stop-Transcript
	exit 2
}

# stop logging
Stop-Transcript

# if we get here then the host is reachable and the credentials are valid
exit 0
