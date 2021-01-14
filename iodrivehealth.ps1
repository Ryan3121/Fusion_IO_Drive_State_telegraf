#status for everything
$iostatus = fio-status.exe -a

#total write in bytes
$iowrite = $iostatus | select-string "Physical bytes written"
$iowrite1 = $iowrite -replace '\D+(\d+)','$1'
$iowriteuse = "IO_Total_Write=" + $iowrite1

#total readin bytes
$ioread =  $iostatus | Select-String "Physical bytes read"
$ioread1 = $ioread -replace '\D+(\d+)','$1'

#temp stats in ^C
$iotemp = $iostatus | select-string "Internal temperature"
$iocurrenttemp = $iotemp.ToString().SubString(23,5)
$iomaxtemp = $iotemp.ToString().SubString(39,5)

#% left in reserve - not exact as it will go from a 5 digit to a 4 digit when going from 100 to 99. 10000 is 100
$ioreserve = $iostatus | select-string "Reserve space status"
$ioreserve1 = $ioreserve.ToString().SubString(35, 20)
$ioreserve2 = $ioreserve1 -replace "[^0-9]" , ''

#% life left 8880 is 88.80%
$iopbw = $iostatus | select-string "Rated PBW" 
$iopbw1 = $iopbw.ToString().SubString(22, 5)  -replace '\D+(\d+)','$1'

#hostname
$hostname6 = "host="
$hostname = $hostname6 
$hostname1 = hostname
$hostname2 = $hostname + $hostname1

#stitching it all together

$iotitle = "IO_Drive_Status"


$iowriteuse = "IO_Total_Write=" + $iowrite1
$ioreaduse = "IO_Total_Read=" + $ioread1
$iotempcurrentuse = "IO_Current_Temp=" + $iocurrenttemp
$iomaxtemp = "IO_Max_Temp=" + $iomaxtemp
$ioreserveuse = "IO_Reserve_left=" + $ioreserve2
$iopwbuse = "IO_Percent_Life_Left=" + $iopbw1



$postt = "$iotitle,$hostname2 $iowriteuse,$ioreaduse,$iotempcurrentuse,$iomaxtemp,$ioreserveuse,$iopwbuse"





Invoke-WebRequest 'http://192.168.0.58:8086/write?db=telegraf' -method post  -body "$postt"
