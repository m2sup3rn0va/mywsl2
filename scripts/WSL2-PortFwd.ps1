$wsl2IP = bash.exe -c "ip addr | grep -Ee 'inet 172'"
$found = $wsl2IP -match '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}';

if( $found )
{
  $wsl2IP = $matches[0];
}
else
{
  echo "Not able to find WSL2 IP Address";
  exit;
}

#[Ports]
#All the ports you want to forward separated by comma
$hostPorts=@(8080);

#[Static ip]
#You can change the addr to your ip config to listen to a specific address
$hostIP='0.0.0.0';
$wsl2Ports = $hostPorts -join ",";

#Remove Firewall Exception Rules
iex "Remove-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' ";

#adding Exception Rules for inbound and outbound Rules
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Outbound -LocalPort $wsl2Ports -Action Allow -Protocol TCP";
iex "New-NetFireWallRule -DisplayName 'WSL 2 Firewall Unlock' -Direction Inbound -LocalPort $wsl2Ports -Action Allow -Protocol TCP";

for( $i = 0; $i -lt $hostPorts.length; $i++ )
{
  $port = $hostPorts[$i];
  iex "netsh interface portproxy delete v4tov4 listenport=$port listenaddress=$hostIP";
  iex "netsh interface portproxy add v4tov4 listenport=$port listenaddress=$hostIP connectport=$port connectaddress=$wsl2IP";
}

echo "FINISHED"