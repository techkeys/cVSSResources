New-xDscResource -Name cVSSTaskScheduler -FriendlyName cVSSTaskScheduler -ModuleName cVSS -Path . -Force -Property @(
    New-xDscResourceProperty -Name DriveLetterOrVolume -Type String -Attribute Key -Description "Drive Letter. Example: C: or \\?\Volume{71edc813-99d3-4135-a22c-f415142b87cb}\"
    New-xDscResourceProperty -Name TaskName -Type String -Attribute Write -Description "Name of the Scheduled Task"
    New-xDscResourceProperty -Name TriggerTime -Type String[] -Attribute Write -Description "Time the Scheduled Task should run.  Example: 7:00AM"
    New-xDscResourceProperty -Name ScheduleType -Type String -Attribute Write -ValidateSet "Daily", "Weekly" -Description "Type of schedule. i.e. Daily or Weekly"
    New-xDscResourceProperty -Name DaysOfWeek -Type String[] -Attribute Write -ValidateSet "Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday" -Description "Days of week schedule should run. Only applicable for ScheduleType 'Weekly'."
    New-xDscResourceProperty -Name FrequencyOfSchedule -Type Uint32 -Attribute Write -Description "Frequency or interval of schedule. If daily, every X days. If weekly, every X weeks."
    New-xDscResourceProperty -Name Ensure -Type String -Attribute Write -ValidateSet "Absent", "Present"
)
