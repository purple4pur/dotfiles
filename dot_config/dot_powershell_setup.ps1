$EDITOR = if (Test-Path variable:EDITOR) { $EDITOR } else { "notepad.exe" }
Function vims { & $EDITOR $PROFILE $args }

Function gad { & git add $args }
Function gb { & git branch $args }
Function gcmt { & git commit $args }
Function gco { & git checkout $args }
Function gd { & git diff $args }
Function gdt { & git difftool $args }
Function glg { & git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short $args }
Function gst { & git status $args }

if (Get-Command starship -ErrorAction SilentlyContinue) {
    Invoke-Expression (&starship init powershell)
}