function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
		[parameter(Mandatory = $true)]
		[System.String]
		$TaskName
	)

    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    If($?){
        $EnsureResult = $True
        }
    Else{
        $EnsureResult = $False
        }

	$returnValue = @{
		TaskName = $TaskName
		Ensure = $EnsureResult
        Drive = $Drive
        TriggerTime = $Task.Triggers.StartBoundary
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
		$TaskName,

		[System.String]
		$TriggerTime,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[System.String]
		$Drive
	)

    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    If($? -eq $True -and $Ensure -eq "Present"){
        Write-Verbose "Removing existing task named $TaskName and recreating"
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$False
        $Action = New-ScheduledTaskAction -Execute C:\Windows\System32\vssadmin.exe -Argument "Create Shadow /For=$Drive"
        $Trigger = New-ScheduledTaskTrigger -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -Weekly -At $TriggerTime
        Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action -Description "Shadow Copy for $Drive" -User SYSTEM -RunLevel Highest
        }
    ElseIf($? -eq $True -and $Ensure -eq "Absent"){
        Write-Verbose "Removing existing task named $TaskName"
        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$False
        }
    ElseIf($? -eq $False -and $Ensure -eq "Present"){
        Write-Verbose "Creating task named $TaskName"
        $Action = New-ScheduledTaskAction -Execute C:\Windows\System32\vssadmin.exe -Argument "Create Shadow /For=$Drive"
        $Trigger = New-ScheduledTaskTrigger -DaysOfWeek Monday,Tuesday,Wednesday,Thursday,Friday -Weekly -At $TriggerTime
        Register-ScheduledTask -TaskName $TaskName -Trigger $Trigger -Action $Action -Description "Shadow Copy for $Drive" -User SYSTEM -RunLevel Highest
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
		$TaskName,

		[System.String]
		$TriggerTime,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure,

		[System.String]
		$Drive
	)

    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    If($? -eq $True -and $Ensure -eq "Present"){
        $Actions = $Task.Actions.Arguments
        $TaskTime = $Task.Triggers.StartBoundary
        $NewTime = $TriggerTime.Substring(0,$TriggerTime.Length-2)

            If($Actions.Contains($Drive) -and $TaskTime.Contains($NewTime)){
                Write-Verbose "The specified Drive and TriggerTime exist.  No changes required"
                $Result = $True
            }
            Else{
                Write-Verbose "Either the specified Drive or TriggerTime is not correct.  Changes required"
                $Result = $False
            }
        }
    ElseIf($? -eq $False -and $Ensure -eq "Absent"){
        $Result = $True
        }
    ElseIf($? -eq $True -and $Ensure -eq "Absent"){
        $Result = $False
        }

	Write-Verbose "Result is $Result"
	$Result

}



Export-ModuleMember -Function *-TargetResource







