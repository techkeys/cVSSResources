Configuration EnsureVSS{

    Import-DscResource -ModuleName cVSS

    node $YourNode{

        cVSS SetShadowCopy{
            Drive = "C:"
            Enable = $True
            StorageLocation = "C:"
            MaxSize = "2048MB"
        }

      cVSSTaskScheduler SevenAM{
          TaskName = "ShadowCopyVolume7AM"
          Ensure = "Absent"
          DriveLetterOrVolume = "C:"
          TriggerTime = "7:00AM"
      }
      
       cVSSTaskScheduler NineAM{
           TaskName = "ShadowCopyVolume9AM"
           Ensure = "Present"
           DriveLetterOrVolume = "C:"
           TriggerTime = "9:00AM"
       }
      
       cVSSTaskScheduler Noon{
           TaskName = "ShadowCopyVolumeNoon"
           Ensure = "Present"
           DriveLetterOrVolume = "C:"
           TriggerTime = "12:00PM"
       }
    }
}


EnsureVSS -OutputPath $YourPath

Start-DscConfiguration -Wait -Force -Verbose -Path $YourPath -ComputerName $YourComputerName