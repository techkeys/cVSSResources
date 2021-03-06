function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Drive,

		[parameter(Mandatory = $true)]
		[System.String]
		$StorageLocation,

		[parameter(Mandatory = $true)]
		[System.Boolean]
		$Enable,

		[parameter(Mandatory = $true)]
		[System.String]
		$MaxSize
	)

	$returnValue = @{
		Drive = $Drive
		StorageLocation = $StorageLocation
		Enable = $Enable
		MaxSize = $MaxSize
	}

	$returnValue
}

function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Drive,

		[parameter(Mandatory = $true)]
		[System.String]
		$StorageLocation,

		[parameter(Mandatory = $true)]
		[System.Boolean]
		$Enable,

		[parameter(Mandatory = $true)]
		[System.String]
		$MaxSize
	)

    $DriveInfo = (Get-WmiObject -Class Win32_Volume | Where-Object DriveLetter -EQ $Drive)
    $Volume = $DriveInfo.DeviceID
    $VSS = Get-WmiObject -Class Win32_ShadowCopy | Select-Object VolumeName


    If($Enable -eq $True -and $VSS.VolumeName -notcontains $Volume){
        Write-Verbose "Enabling VSS on $Drive"
        vssadmin add shadowstorage /For=$Drive /On=$StorageLocation /MaxSize=$MaxSize
        vssadmin create shadow /For=$Drive /AutoRetry=15
    }
    ElseIf($Enable -eq $False -and $VSS.VolumeName -contains $Volume) {
        Write-Verbose "Disabling VSS on $Drive"
        vssadmin delete shadows /All /Quiet
        vssadmin delete shadowstorage /For=$Drive /On=$StorageLocation         
    }
}

function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$Drive,

		[parameter(Mandatory = $true)]
		[System.String]
		$StorageLocation,

		[parameter(Mandatory = $true)]
		[System.Boolean]
		$Enable,

		[parameter(Mandatory = $true)]
		[System.String]
		$MaxSize
	)

    $DriveInfo = (Get-WmiObject -Class Win32_Volume | Where-Object DriveLetter -EQ $Drive)
    $Volume = $DriveInfo.DeviceID
    $VSS = Get-WmiObject -Class Win32_ShadowCopy | Select-Object VolumeName

    If($VSS.VolumeName -contains $Volume -and $Enable -eq $True){
        Write-Verbose "VSS is already Enabled for $Drive"
        $Result = $True
        }
    ElseIf($VSS.VolumeName -contains $Volume -and $Enable -eq $False){
        Write-Verbose "VSS is Enabled on $Drive and should not be.  Proceeding to Disable VSS on $Drive"
        $Result = $False
    }
    ElseIf($VSS.VolumeName -notcontains $Volume -and $Enable -eq $False){
        Write-Verbose "VSS is not Enabled on $Drive and should not be"
        $Result = $True
        }
    ElseIf($VSS.VolumeName -notcontains $Volume -and $Enable -eq $True){
        Write-Verbose "VSS is not Enabled on $Drive.  Proceeding to Enable VSS on $Drive"
        $Result = $False
    }

    $Result
}

Export-ModuleMember -Function *-TargetResource
