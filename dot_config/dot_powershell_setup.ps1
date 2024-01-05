# ----------
#   Common
# ----------
$EDITOR = if (Test-Path variable:EDITOR) { $EDITOR } else { "notepad.exe" }
Function vims { & $EDITOR $PROFILE $args }

# -------------
#   Git Alias
# -------------
Function gad { & git add $args }
Function gb { & git branch $args }
Function gcmt { & git commit $args }
Function gco { & git checkout $args }
Function gd { & git diff $args }
Function gdt { & git difftool --dir-diff $args }
Function glg { & git log --graph --pretty='%Cred%h%Creset -%C(auto)%d%Creset %s %Cgreen(%ad) %C(bold blue)<%an>%Creset' --date=short $args }
Function gst { & git status $args }

# ------------
#   Starship
# ------------
Invoke-Expression (&starship init powershell)

# ----------
#   Zoxide
# ----------
Invoke-Expression (& {
    $hook = if ($PSVersionTable.PSVersion.Major -lt 6) { 'prompt' } else { 'pwd' }
    (zoxide init --hook $hook powershell | Out-String)
})