if ($IsLinux) {
  $dirs = @'
.bun
.cargo
.local/bin
.local/flutter
.local/nodejs
.local/numbat
.local/share/applications
.local/share/bash-completion/completions
.local/share/com.pais.handy
.local/share/fonts
.local/share/gnome-shell/extensions
.local/share/icons
.local/share/jar
.local/share/man
.local/share/pnpm
.local/share/powershell
.local/share/uv
.nuget/packages
.rustup
.vscode/extensions
Desktop
Documents
Downloads
go
Music
p
Pictures
Public
Templates
Videos
'@.Split("`n")
  tar -C $HOME --zstd -cf home.tar.zst $dirs
  $dirs = @'
/opt/microsoft/powershell/7
/usr/local/bin/go
/usr/local/bin/gofmt
/usr/local/go
'@.Split("`n")
  tar -C / --zstd -cf ~/system.tar.zst $dirs
}
else {
  throw [System.NotImplementedException]::new()
}
