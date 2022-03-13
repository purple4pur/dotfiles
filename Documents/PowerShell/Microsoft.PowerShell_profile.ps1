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

Function gad {
    $a = $args -join " "
    git add $a
}

Function gcmt {
    $a = $args -join " "
    git commit $a
}

Function pipins {
    $a = $args -join " "
     pip install -i https://pypi.tuna.tsinghua.edu.cn/simple $a
}