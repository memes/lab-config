---
k8s_master: true
k8s_worker: true
vlan100_addresses:
  - 172.24.1.0/13
  - 2001:470:49a5:8::1:0/64
