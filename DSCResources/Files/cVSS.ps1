#Name the Resource
#$ResourceName = '<ResourceName'
$ResourceName = 'cVSS'

#Create Module Path
$ResourcePath = $SomePath

Import-Module -Name xDSCResourceDesigner

#Create the Resource and define Resource properties
New-xDSCResource -Name $ResourceName -Path $ResourcePath -ClassVersion 1.0 -Force -Property $(
    New-xDscResourceProperty -Name Drive -Type String -Attribute Key -Description "Drive Letter. Example:  C:"
    New-xDscResourceProperty -Name StorageLocation -Type String -Attribute Required -Description "Drive Letter to store Shadow Copies on. Example: C:"
    New-xDscResourceProperty -Name Enable -Type Boolean -Attribute Required -Description "Enable or Disable VSS on specified volume"
    New-xDscResourceProperty -Name MaxSize -Type String -Attribute Required -Description "Specified in Bytes.  Example:  2048MB"
    )

#If needed, use Update-xDSCResource if you add/remove any parameters from the resource
#Update-xDscResource -Name $ResourceName -Property $ProductKey,$Activate -ClassVersion 1.0 -Force
Update-xDscResource -Name $ResourceName -ClassVersion 1.0 -Force -Property $(
    New-xDscResourceProperty -Name Drive -Type String -Attribute Key -Description "Drive Letter. Example:  C:"
    New-xDscResourceProperty -Name StorageLocation -Type String -Attribute Required -Description "Drive Letter to store Shadow Copies on. Example: C:"
    New-xDscResourceProperty -Name Enable -Type Boolean -Attribute Required -Description "Enable or Disable VSS on specified volume"
    New-xDscResourceProperty -Name MaxSize -Type String -Attribute Required -Description "Specified in Bytes.  Example:  2048MB"
    )

#Test the schema after updating or creating
Test-xDscSchema -Path $SomePath