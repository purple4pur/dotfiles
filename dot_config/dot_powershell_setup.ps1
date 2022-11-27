Function vims {
    $a = $args -join " "
    gvim ~\.config\.powershell_setup.ps1 $a &
}
Function srcs {
    . ~\.config\.powershell_setup.ps1
}
Function jj {
    Get-Job -State Running
}

# ------  git alias  ------
Function gst {
    $a = $args -join " "
    git status $a
}
Function glg {
    $a = $args -join " "
    git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short $a
}
Function gad {
    $a = $args -join " "
    git add $a
}
Function gcmt {
    $a = $args -join " "
    git commit $a
}

# ------  starship  ------
Invoke-Expression (&starship init powershell)

# ------  zoxide  ------
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell --cmd cd | Out-String)
})