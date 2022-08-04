### Windows

```
cmd /C mklink /J "C:\Users\<USERNAME>\vimfiles" "C:\Users\<USERNAME>\.vim"
cmd /C mklink /J "C:\Users\<USERNAME>\AppData\Roaming\mpv" "C:\Users\<USERNAME>\.config\mpv"
```

### Linux

- bash

```
echo "source ~/.config/.bash_setup" >> ~/.bashrc
```