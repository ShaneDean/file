# 前言

[参考](https://wiki.libvirt.org/page/VirtualNetworking)

# 配置

网络配置只会在libvirtd服务启动的时候生效，如果libvirtd自动启动，那么会自动生效，如果libvirtd手动启动，那么在启动之前guest无法访问vswitch

-   NAT (Network Address Translation)  (默认)

guest vm使用host的ip地址和外部通信。外部的设备无法直接和guest通信

NAT模式下需要依赖iptables规则, 如果规则失效 那么 guest无法访问网络

-   Routed 
    
vswitch直接连接host的LAN，不需要NAT来传递guest的网络包。

vswitch通过检查每个packet中包含的ip 地址来决定交给哪个guest处理

这个模式下，所有的vm都在vswitch的子网中。但物理网络中的设备不知道这个子网中有哪些设备，需要每个vm配置一个物理网络的路由配置(static route)

-   Isolated

这个模式下，vm可以访问vswitch和其他的vm。但它们不能包到外面也不能接收外面的包。

##  补充

libvirt使用 dnsmasq来为vm提供dhcp和dns服务

libvirt支持对vm内部的网络流量绑定到指定网卡