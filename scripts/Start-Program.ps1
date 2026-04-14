[CmdletBinding()]
param (
  [Parameter(Mandatory, Position = 0)]
  [ValidateSet('vmware', 'vmplayer')]
  [string]
  $Name
)

switch ($Name) {
  { $_ -ceq 'vmware' -or $_ -ceq 'vmplayer' } {
    sudo { ('VMAuthdService', 'VMnetDHCP', 'VMUSBArbService', 'VMware NAT Service').ForEach{ Set-Service $_ -Status Running } }
    Start-Process -FilePath "C:\Program Files (x86)\VMware\VMware Workstation\$_.exe" -WorkingDirectory 'C:\Program Files (x86)\VMware\VMware Workstation'
    break
  }
}
