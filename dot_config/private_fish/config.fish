starship init fish | source

set -U fish_greeting

set -gx NEMU_HOME /home/purple/workspace/ysyx-workbench/nemu
set -gx AM_HOME /home/purple/workspace/ysyx-workbench/abstract-machine
set -gx VERILATOR_ROOT /home/purple/opt/verilator
set -gx NVBOARD_HOME /home/purple/workspace/ysyx-workbench/nvboard

fish_add_path /usr/lib/ccache
fish_add_path /home/purple/.local/bin
