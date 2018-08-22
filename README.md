## Introduction ##
Scripts for running multiple mochimo nodes (so that it can be mined with multiple CPUs or GPUs) on the same computer using network namespaces.

## Requirements ##
* tmux
* bridge-utils

## How to use ##
(Modify paths to match your paths)
Steps 1 to 3 only needs to be done once.
Step 4 needs to run every boot.
1. Make a copy of your usual mochi folder: `cp -a ~/mochi ~/mochi-slave`
2. Copy these scripts and coreip.lst into mochi-slave/bin folder: `cp *.sh coreip.lst ~/mochi-slave/bin/`
3. Modify `~/mochi-slave/bin/run_all.sh` to match your number of CPUs or GPUs.
4. Add firewall NAT rules so that the slave nodes can access the internet: `cd ~/mochi-slave/bin; sudo ./start_firewall.sh`
5. Start the regular node as usual. This will become your main node: `cd ~/mochi/bin; ./gomochi d`
6. Wait for the main node to complete syncing.
7. Start the slave nodes: `cd ~/mochi-slave/bin; sudo ./run_all.sh`
8. To monitor your slave nodes, attach to tmux: `sudo tmux a -t mochi`
