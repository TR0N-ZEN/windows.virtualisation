## clone-vm

Download an .iso file for a long-term-support version of ubuntu server from  
  https://ubuntu.com/download/server#manual-install.  
Create a VM named *ubuntu-PROTOTYPE* with Hyper-V and run through the installation process.
Shutdown the VM and execute the following scripts accordingly:

+ `.\clone-vm.ps1 PROTOTYPE 0 6` to clone a VM, as many times as you want
+ `.\remove-cloned-vm.ps1 0 6` once to clean up your (git) workspace



## after cloning a vm running linux 

+ `.\start-vm.ps1 1 6` to boot the vms
+ log into all vms `.\ssh-into-vm.ps1 "1-6"`
  + update the hostname `hostnamectl hostname <new-hostname>`
  + update the machine-id according to https://wiki.debian.org/MachineId
    ```bash
    rm -f /etc/machine-id /var/lib/dbus/machine-id
    dbus-uuidgen --ensure=/etc/machine-id
    dbus-uuidgen --ensure 
    ```
+ create a checkpoint e.g. named "individualized"
  ```
  .\checkpoint-vm.ps1 "1-6" "individualized"
  ```
