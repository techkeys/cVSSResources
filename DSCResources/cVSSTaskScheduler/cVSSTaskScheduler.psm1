function Get-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Collections.Hashtable])]
	param
	(
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
		[System.String]
		$DriveLetterOrVolume,
        
        [parameter()]
		[System.String]
		$TaskName,

        [parameter()]
        [ValidateSet("Daily", "Weekly")]
        [System.String]
        $ScheduleType = "Weekly",

        [parameter()]
        [System.Int32]
        $FrequencyOfSchedule = 1,

        [parameter()]
        [ValidateSet("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")]
        [System.String[]]
        $DaysOfWeek,

		[System.String[]]
		$TriggerTime,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure
	)

    $volume = Get-VolumeFromDriveLetterOrPath -DriveLetterOrVolume $DriveLetterOrVolume

    $volumeGuid = $null

    if($null -ne $volume)
    {
        Write-Verbose -Message "Found volume $($volume.Path)."
        if($volume.Path -match '{([a-f0-9\-]*)}')
        {
            $volumeGuid = $Matches[1]
            if($null -eq $TaskName -or '' -eq $TaskName)
            {
                $TaskName = "ShadowCopyVolume{$volumeGuid}"
            }
            $DriveLetterOrVolume = $volume.Path
        }
    }

    if($null -eq $volume)
    {
        Write-Error -Message "Volume not found for drive letter '$DriveLetterOrVolume'!"
        $result = $true
    }
    elseif($null -eq $TaskName -or '' -eq $TaskName)
    {
         Write-Error -Message "Task name '$TaskName' not valid!"
        $result = $true
    }
    else
    {
        $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

        if($null -eq $Task)
        {
            $EnsureResult = $True
        }
        else
        {
            $EnsureResult = $False
        }

        $returnValue = @{
            TaskName = $TaskName
            Ensure = $EnsureResult
            DriveLetterOrVolume = $DriveLetterOrVolume
            TriggerTime = $Task.Triggers.StartBoundary
        }
    }

	$returnValue
}

function Set-TargetResource
{
	[CmdletBinding()]
	param
	(
		[parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
		[System.String]
		$DriveLetterOrVolume,
        
        [parameter()]
		[System.String]
		$TaskName,

        [parameter()]
        [ValidateSet("Daily", "Weekly")]
        [System.String]
        $ScheduleType = "Weekly",

        [parameter()]
        [System.Int32]
        $FrequencyOfSchedule = 1,

        [parameter()]
        [ValidateSet("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")]
        [System.String[]]
        $DaysOfWeek,

		[System.String[]]
		$TriggerTime,

		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure        
	)

    $volume = Get-VolumeFromDriveLetterOrPath -DriveLetterOrVolume $DriveLetterOrVolume

    $volumeGuid = $null

    if($null -ne $volume)
    {
        if($volume.Path -match '{([a-f0-9\-]*)}')
        {
            $volumeGuid = $Matches[1]
            if($null -eq $TaskName -or '' -eq $TaskName)
            {
                $TaskName = "ShadowCopyVolume{$volumeGuid}"
            }
            $DriveLetterOrVolume = $volume.Path
        }
    }

    Write-Verbose -Message "Getting Task for task name '$TaskName'"
    $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

    if($null -ne $Task)
    {
        Write-Verbose -Message "Found task '$TaskName'"
        if($Ensure -eq 'Present')
        {
            Write-Verbose -Message "Removing existing task named '$TaskName'"
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false

            $createTaskParams = $PSBoundParameters
            $createTaskParams.Remove('Ensure')
            $createTaskParams.Add('TaskName', $TaskName)
            $createTaskParams['DriveLetterOrVolume'] = $volume.Path;
            New-VssSchedule @createTaskParams
        }
        elseif($Ensure -eq 'Absent')
        {
            Write-Verbose -Message "Removing existing task named $TaskName"
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        }
    }
    else
    {
        Write-Verbose -Message "Could not find task '$TaskName'"
        if($Ensure -eq 'Present')
        {
            $createTaskParams = $PSBoundParameters
            $createTaskParams.Remove('Ensure')
            $createTaskParams.Add('TaskName', $TaskName)
            $createTaskParams['DriveLetterOrVolume'] = $volume.Path;
            New-VssSchedule @createTaskParams
        }
    }
}

function Test-TargetResource
{
	[CmdletBinding()]
	[OutputType([System.Boolean])]
	param
	(
		[parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
		[System.String]
		$DriveLetterOrVolume,

        [parameter()]
		[System.String]
		$TaskName,

        [parameter()]
        [ValidateSet("Daily", "Weekly")]
        [System.String]
        $ScheduleType = "Weekly",

        [parameter()]
        [System.Int32]
        $FrequencyOfSchedule = 1,

        [parameter()]
        [ValidateSet("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")]
        [System.String[]]
        $DaysOfWeek,

        [parameter()]
		[System.String[]]
		$TriggerTime = '13:00',

        [parameter()]
		[ValidateSet("Present","Absent")]
		[System.String]
		$Ensure
	)

    Write-Verbose -Message "Looking up volume for DriveLetterOrVolume '$DriveLetterOrVolume'"
    
    $volume = Get-VolumeFromDriveLetterOrPath -DriveLetterOrVolume $DriveLetterOrVolume
    
    $volumeGuid = $null

    if($null -ne $volume)
    {
        Write-Verbose -Message "Found volume $($volume.Path)."
        if($volume.Path -match '{([a-f0-9\-]*)}')
        {
            $volumeGuid = $Matches[1]
            if($null -eq $TaskName -or '' -eq $TaskName)
            {
                $TaskName = "ShadowCopyVolume{$volumeGuid}"
            }
            $DriveLetterOrVolume = $volume.Path
        }
    }

    if($null -eq $volume)
    {
        Write-Error -Message "Volume not found for drive letter '$DriveLetterOrVolume'!"
        $result = $true
    }
    elseif($null -eq $TaskName -or '' -eq $TaskName)
    {
         Write-Error -Message "Task name '$TaskName' not valid!"
        $result = $true
    }
    else
    {
        $Task = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue

        if($null -ne $Task)
        {
            if($Ensure -eq 'Present')
            {
                $actions = $Task.Actions.Arguments
                $triggers = $Task.Triggers
                $taskTime = $Triggers.StartBoundary

                if($null -ne $triggers){
                    if($triggers.GetType().Name -eq "CimInstance")
                    {
                        $triggers = @($triggers)
                    }
                }

                if($null -ne $taskTime){
                    if($taskTime.GetType().Name -eq "CimInstance")
                    {
                        $taskTime = @($taskTime)
                    }
                }

                Write-Verbose "Matching VSS scheduled snapshot times."

                $triggerResult = $false

                foreach($trigger in $triggers)
                {
                    if($trigger.CimSystemProperties.ClassName -eq "MSFT_TaskDailyTrigger")
                    {
                        if($ScheduleType -ne 'Daily')
                        {
                            $triggerResult = $false
                        }
                        else
                        {
                            [bool] $timeScheduleExists = $false
                            $taskTime | ForEach-Object { $timeScheduleExists = $timeScheduleExists -bor $_.Contains($newTime) }

                            if($timeScheduleExists) {
                                $triggerResult = $true
                            }
                        }
                    }
                    elseif($trigger.CimSystemProperties.ClassName -eq "MSFT_TaskWeeklyTrigger")
                    {
                        if($ScheduleType -ne 'Weekly')
                        {
                            $triggerResult = $false
                        }
                        else
                        {
                            [bool] $timeScheduleExists = $false
                            $taskTime | ForEach-Object { $timeScheduleExists = $timeScheduleExists -bor $_.Contains($newTime) }

                            Write-Verbose -Message "Time schedule already exists status: $timeScheduleExists"

                            if($timeScheduleExists) {
                                $triggerResult = $true
                                $triggerDaysOfWeek = ConvertTo-DaysOfWeekArray -DaysOfWeekMask $trigger.DaysOfWeek
                                if($null -eq (Compare-Object -ReferenceObject $DaysOfWeek -DifferenceObject $triggerDaysOfWeek)){
                                    Write-Verbose -Message "The weekly schedule days of week do not match."
                                    $triggerResult = $false
                                }
                            }
                        }
                    }
                }

                if($actions.Contains("/For=$DriveLetterOrVolume"))
                {
                    Write-Verbose "The specified Drive exists. No changes required"
                    $actionResult = $true
                }
                else
                {
                    Write-Verbose "The specified Drive is not correct.  Changes required"
                    $actionResult = $false
                }

                $result = $triggerResult -band $actionResult
            }
            elseif($Ensure -eq 'Absent')
            {
                $result = $false
            }
        }
        elseif($null -eq $Task -and $Ensure -eq 'Absent')
        {
            $result = $true
        }
    }

	Write-Verbose "Result is $result"
	$result
}

function Get-VolumeFromDriveLetterOrPath 
{
    param(
        [Parameter(Mandatory,Position=0)]
        [ValidateNotNullOrEmpty()]
        [System.String]
        $DriveLetterOrVolume
    )

    if($DriveLetterOrVolume -match '^(\w):?\\?')
    {
        Write-Verbose -Message "Found drive letter match '$($Matches[1])'."

        $DriveLetterOrVolume = $Matches[1]
        $volume = Get-Volume | Where-Object { $_.DriveLetter -eq $DriveLetterOrVolume }
    }
    elseif($DriveLetterOrVolume -match '^(\\\\\?\\Volume{[a-f0-9\-]*})\\?$')
    {
        Write-Verbose -Message "Found volume path match $($Matches[1])."

        $VolumePath = $Matches[1] + '\'
        $volume = Get-Volume | Where-Object { $_.Path -eq $VolumePath }
    }

    return $volume
}

function New-VssSchedule
{
    param(
        [parameter(Mandatory)]
        [String]
        $DriveLetterOrVolume,

        [parameter(Mandatory)]
		[System.String]
		$TaskName,

        [parameter()]
        [ValidateSet("Daily", "Weekly")]
        [System.String]
        $ScheduleType = "Weekly",

        [parameter()]
        [System.Int32]
        $FrequencyOfSchedule = 1,

        [parameter()]
        [ValidateSet("Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday")]
        [System.String[]]
        $DaysOfWeek,

        [parameter()]
		[System.String[]]
		$TriggerTime,

        [switch]
        $PassThru
    )

    Write-Verbose -Message "Creating Vss schedule named $TaskName for $DriveLetterOrVolume with ScheduleType '$ScheduleType'"

    $triggers = @()

    if($ScheduleType -eq 'Daily')
    {        
        foreach($trigger in $TriggerTime){
            Write-Verbose -Message "Creating new trigger for times $($TriggerTime -join ',') every $FrequencyOfSchedule days."
            $triggers += New-ScheduledTaskTrigger -Daily -DaysInterval $FrequencyOfSchedule -At $trigger
        }
    }
    elseif($ScheduleType -eq 'Weekly')
    {
        foreach($trigger in $TriggerTime){
            Write-Verbose -Message "Creating new trigger for times $($TriggerTime -join ',') on $($DaysOfWeek -join ',') every $FrequencyOfSchedule week(s)."            
            $triggers += New-ScheduledTaskTrigger -Weekly -DaysOfWeek $DaysOfWeek  -At $trigger
        }
    }

    $Action = New-ScheduledTaskAction -Execute 'C:\Windows\System32\vssadmin.exe' -Argument "Create Shadow /AutoRetry=15 /For=$DriveLetterOrVolume" -WorkingDirectory "%systemroot%\system32"

    Write-Verbose "Registering new schedule task."
    $RegisterScheduledTaskParams = @{
        TaskName = $TaskName
        ScheduleType = $ScheduleType
        Trigger = $triggers
        Action = $Action
        User = "SYSTEM"
        RunLevel = "Highest"
        Description = "Shadow Copy for $DriveLetterOrVolume" 
    }

    if($TaskName -match "^ShadowCopyVolume{[a-f0-9\-]*}$")
    {
        Write-Verbose -Message ("Registering scheduled task as V1")
        Register-ScheduledTaskV1 $RegisterScheduledTaskParams
    }
    else
    {
        Register-ScheduledTask @RegisterScheduledTaskParams
    }

    if($PassThru){
        return Get-ScheduledTask -TaskName $TaskName
    }
}

function Register-ScheduledTaskV1 
{
    param(
        [parameter(Mandatory,Position=0)]
        [Hashtable]
        $RegisterScheduledTaskParams
    )

    Start-Process -FilePath "$($env:SystemRoot)\System32\schtasks.exe" -WorkingDirectory "$($env:SystemRoot)\System32" -ArgumentList "/Create /TN `"$($RegisterScheduledTaskParams['TaskName'])`" /SC $($RegisterScheduledTaskParams['ScheduleType']) /tr `"$($env:SystemRoot)\System32\vssadmin.exe`" /V1 /RU SYSTEM" -Wait
    Set-ScheduledTask -TaskName $RegisterScheduledTaskParams['TaskName'] -Trigger $RegisterScheduledTaskParams['Trigger'] -Action $RegisterScheduledTaskParams['Action']
}

function ConvertTo-DaysOfWeekArray
{
    param(
        [parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [System.Uint16]
        $DaysOfWeekMask
    )
    $DaysOfWeek = @()

    if(($DaysOfWeekMask -shl 15) -eq 32768){ $DaysOfWeek += "Sunday" }
    if((($DaysOfWeekMask -shr 1) -shl 15) -eq 32768){ $DaysOfWeek += "Monday" }
    if((($DaysOfWeekMask -shr 2) -shl 15) -eq 32768){ $DaysOfWeek += "Tuesday" }
    if((($DaysOfWeekMask -shr 3) -shl 15) -eq 32768){ $DaysOfWeek += "Wednesday" }
    if((($DaysOfWeekMask -shr 4) -shl 15) -eq 32768){ $DaysOfWeek += "Thursday" }
    if((($DaysOfWeekMask -shr 5) -shl 15) -eq 32768){ $DaysOfWeek += "Friday" }
    if((($DaysOfWeekMask -shr 6) -shl 15) -eq 32768){ $DaysOfWeek += "Saturday" }

    return $DaysOfWeek
}

Export-ModuleMember -Function *-TargetResource
