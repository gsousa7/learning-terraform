add-content -path c:/users/derek/.ssh/config -value @'

Host ${host}
  HostName ${hostname}
  User ${user}
  IdentityFile ${identityfile}
'@