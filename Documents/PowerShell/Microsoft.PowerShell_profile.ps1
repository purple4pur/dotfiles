# Call Starship
Invoke-Expression (&starship init powershell)

Function gst {
    $a = $args -join " "
    git status $a
}

Function glg {
    $a = $args -join " "
    git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short $a
}