# may/23/2015 22:21:52 by RouterOS 6.28
#
/interface bridge
add admin-mac=4C:5E:0C:A7:17:AA auto-mac=no mtu=1500 name=lan
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n channel-width=\
    20/40mhz-ht-above disabled=no distance=indoors l2mtu=2290 mode=ap-bridge \
    ssid=Mikrotik_Home wireless-protocol=802.11
/interface ethernet
set [ find default-name=ether1 ] name=wan
set [ find default-name=ether2 ] name=ether2-master-local
set [ find default-name=ether3 ] master-port=lan name=\
    ether3-slave-local
set [ find default-name=ether4 ] master-port=lan name=\
    ether4-slave-local
set [ find default-name=ether5 ] master-port=lan name=\
    ether5-slave-local
/interface wireless security-profiles
set [ find default=yes ] authentication-types=wpa-psk,wpa2-psk mode=\
    dynamic-keys wpa-pre-shared-key=XX45t87ujhtz wpa2-pre-shared-key=\
    XX45t87ujhtz
/ip pool
add name=dhcp ranges=192.168.1.100-192.168.1.200
/ip dhcp-server
add address-pool=dhcp disabled=no interface=lan name=default
/interface bridge port
add bridge=bridge-local interface=ether2-master-local
add bridge=bridge-local interface=wlan1
/ip address
add address=192.168.1.1/24 comment="default configuration" interface=\
    lan network=192.168.1.0
/ip dhcp-client
add comment="default configuration" dhcp-options=hostname,clientid interface=\
    wan
/ip dhcp-server network
add address=192.168.1.0/24 comment="default configuration" dns-server=\
    192.168.1.1 gateway=192.168.1.1 netmask=24
/ip firewall address-list
add address=195.56.148.99 list=backdoor
/ip firewall filter
add chain=input disabled=yes
add chain=input in-interface=!wan
add chain=input connection-state=established,related
add chain=input connection-state=new limit=10/1m,5 protocol=icmp
add chain=input connection-state=new dst-port=22 limit=3,5 protocol=tcp
add chain=input connection-state=new dst-port=8291 limit=3,5 protocol=tcp
add chain=input connection-state=new dst-port=1723 limit=3,5 protocol=tcp
add action=add-src-to-address-list address-list=block address-list-timeout=\
    10m chain=input connection-state=new src-address-list=!block
add action=jump chain=input in-interface=wan jump-target=block \
    src-address-list=block

add chain=forward disabled=yes
add chain=forward connection-state=established,related
add chain=forward in-interface=lan connection-state=new
add action=jump chain=forward connection-state=new in-interface=wan \
    jump-target=block

add chain=block action=add-src-to-address-list address-list=block \
    address-list-timeout=10m connection-state=new src-address-list=!block
add chain=block action=add-src-to-address-list address-list=block \ 
    address-list-timeout=1d connection-state=new src-address-list=block
add action=drop chain=block

/ip firewall nat
add action=masquerade chain=srcnat out-interface=wan to-addresses=\
    0.0.0.0
/system clock
set time-zone-name=Europe/Budapest
