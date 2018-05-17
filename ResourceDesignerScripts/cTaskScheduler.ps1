#Name the Resource
$ResourceName = 'cVSSTaskScheduler'

#Create Module Path
$ResourcePath = $SomePath

Import-Module -Name xDSCResourceDesigner

#Create the Resource and define Resource properties
New-xDSCResource -Name $ResourceName -Path $ResourcePath -ClassVersion 1.0 -Force -Property $(
    New-xDscResourceProperty -Name TaskName -Type String -Attribute Key -Description "Name of the Scheduled Task"
    New-xDscResourceProperty -Name TriggerName -Type String -Attribute Required -Description "Name for Trigger to use with scheduling VSS Tasks"
    New-xDscResourceProperty -Name TriggerDays -Type String[] -Attribute Required -Description "Days the Scheduled Task should run on.  Example: Monday,Tuesday"
    New-xDscResourceProperty -Name TriggerTime -Type String -Attribute Required -Description "Time the Scheduled Task should run.  Example: 7:00AM"
    New-xDscResourceProperty -Name TaskDescription -Type String -Attribute Read -Description "Description for Scheduled Task"
    New-xDscResourceProperty -Name Ensure -Type String -ValidateSet "Present","Absent" -Attribute Read,Required
    )

#If needed, use Update-xDSCResource if you add/remove any parameters from the resource
#Update-xDscResource -Name $ResourceName -Property $ProductKey,$Activate -ClassVersion 1.0 -Force
Update-xDscResource -Name $ResourceName -ClassVersion 1.0 -Force -Property $(
    New-xDscResourceProperty -Name TaskName -Type String -Attribute Key -Description "Name of the Scheduled Task"
    New-xDscResourceProperty -Name TriggerTime -Type String -Attribute Write,Required -Description "Time the Scheduled Task should run.  Example: 7:00AM"
    New-xDscResourceProperty -Name Ensure -Type String -ValidateSet "Present","Absent" -Attribute Write,Required
    New-xDscResourceProperty -Name Drive -Type String -Attribute Write,Required -Description "Drive Letter. Example:  C:"
)

#Test the schema after updating or creating
Test-xDscSchema -Path $SomePath.$ResourceName.schema.mof