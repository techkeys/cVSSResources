Configuration Example_VSSTaskScheduler{

    Import-DscResource -ModuleName cVSS

    node $YourNode{

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

VSSTaskScheduler -OutputPath $YourPath

Start-DscConfiguration -Wait -Force -Verbose -Path $YourPath -ComputerName $YourComputerName