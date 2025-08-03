After running

```
.\create-and-connect-switch.ps1 "0-6" "switch_private" "Private"
.\create-and-connect-switch.ps1 "0-6" "Default Switch"
```


I assign ipv4 addresses to the newly created network interfaces inside the VMs
via netplan which uses
  .yaml files to configure network interfaces and
  networkd as its default backend (meaning it just uses networkd to configure the network).

```
tony@node1:~$ sudo su
root@node1:/home/tony# cat << EOF > /etc/netplan/50-cloud-init.yaml
network:
  version: 2
  ethernets:
    # switch_private
    eth0:
      addresses:
        - 192.168.1.11/24
      routes:
        - to: 192.168.1.0/24
          on-link: true
   # Default switch
    eth1:
      dhcp4: true
EOF

root@node1:/home/tony# exit
tony@node1:~$ sudo netplan apply

tony@node1:~$ ip a
: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host noprefixroute
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:08:69:8b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.11/24 brd 192.168.1.255 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::215:5dff:fe08:698b/64 scope link
       valid_lft forever preferred_lft forever
3: eth1: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc mq state UP group default qlen 1000
    link/ether 00:15:5d:08:69:a4 brd ff:ff:ff:ff:ff:ff
    inet 172.25.92.73/20 metric 100 brd 172.25.95.255 scope global dynamic eth1
       valid_lft 86393sec preferred_lft 86393sec
    inet6 fe80::215:5dff:fe08:69a4/64 scope link
       valid_lft forever preferred_lft forever

tony@node1:~$ ip route
default via 172.25.80.1 dev eth1 proto dhcp src 172.25.92.73 metric 100
172.25.80.0/20 dev eth1 proto kernel scope link src 172.25.92.73 metric 100
172.25.80.1 dev eth1 proto dhcp scope link src 172.25.92.73 metric 100
192.168.1.0/24 dev eth0 proto kernel scope link src 192.168.1.11
```

---

Resources:

1. netplan
  1.1. https://documentation.ubuntu.com/server/explanation/networking/configuring-networks/
  1.2. https://manpages.ubuntu.com/manpages/noble/en/man5/netplan.5.html
    1.2.1. https://documentation.ubuntu.com/server/explanation/networking/configuring-networks/#dynamic-ip-address-assignment-dhcp-client
    1.2.2. https://documentation.ubuntu.com/server/explanation/networking/configuring-networks/#static-ip-address-assignment
2. hyper-v
  2.1. https://documentation.ubuntu.com/server/explanation/networking/configuring-networks/#static-ip-address-assignment
