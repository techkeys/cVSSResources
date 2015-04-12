Configuration TestVSS{

    Import-DscResource -ModuleName cVSS

    node $YourNode{

        cVSS SetShadowCopy{
           Drive = 'C:'
           Enable = $True
           StorageLocation = 'C:'
           MaxSize = '2048MB'
        }
    }

}

TestVSS -OutputPath $YourPath

Start-DscConfiguration -Wait -Force -Verbose -Path $YourPath -ComputerName $YourComputer