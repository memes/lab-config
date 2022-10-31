---
k8s_master: true
k8s_worker: true
k8s_node_name: k8s03.lab.acceleratedgcp.com
vlan100_addresses:
  - 10.100.3.0/13
  - 2001:470:49a5:100:3::0/56
