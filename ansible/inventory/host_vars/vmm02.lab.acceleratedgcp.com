---
k8s_master: true
k8s_worker: true
k8s_node_name: k8s02.lab.acceleratedgcp.com
vlan100_addresses:
  - 172.24.2.0/13
  - 2001:470:49a5:8::2:0/64
