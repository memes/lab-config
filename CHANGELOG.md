# Changelog

## [0.10.1-vpshere](https://github.com/memes/lab-config/compare/v0.10.0-vpshere...v0.10.1-vpshere) (2024-09-13)


### Bug Fixes

* Configure yamllint to match ansible-lint ([57656e7](https://github.com/memes/lab-config/commit/57656e795865df28b5935428ed79a6523187d7d8))
* Modified playbooks and roles to pass linting ([c3d7bb7](https://github.com/memes/lab-config/commit/c3d7bb7cb3fde6c42c0d13397e219c7142686f72))

## [0.10.0-vpshere](https://github.com/memes/lab-config/compare/v0.9.9-vpshere...v0.10.0-vpshere) (2024-09-12)


### Features

* Cillium role ([f21686e](https://github.com/memes/lab-config/commit/f21686ec7df1ddcf5d7d456d96d5ffb75f0b7939))
* kubeadm role for ansible ([015c6f4](https://github.com/memes/lab-config/commit/015c6f4964c7b3b46d4edbcb8e7157aa981cfd25))
* Remove refresh role ([cbb1699](https://github.com/memes/lab-config/commit/cbb1699fcea2bb2e7e831d91f7b344dd5233e540))
* Role to install external-secrets ([41b1e31](https://github.com/memes/lab-config/commit/41b1e314d130c84afddc443f88164bd491561f43))
* Role to install longhorn ([6d9ba42](https://github.com/memes/lab-config/commit/6d9ba425530f3c87a6e5f6b37d2acb2eb5c5dae4))
* Role to perform bare-metal prep for k8s ([bebd0fe](https://github.com/memes/lab-config/commit/bebd0fe25d0ce8cba4700d0e9b686e1ea707051b))
* Split CRI-O provisioning into a role ([1703004](https://github.com/memes/lab-config/commit/1703004d0c76b8fa15468efc61a22abbe6f46646))


### Bug Fixes

* Add cert for new router ([a3fe002](https://github.com/memes/lab-config/commit/a3fe0028cd7803b0f470c951834be56c84c50b41))
* Break package update to a role for reuse ([11e9f28](https://github.com/memes/lab-config/commit/11e9f2857e6cd6495e2036c0944d2af52903676d))
* Certificate generation after network changes ([6fcc5f6](https://github.com/memes/lab-config/commit/6fcc5f6da1eaeb3a9a0d0ee2b4fce33dd07522aa))
* Commit WIP ahead of merge to main ([3a8727f](https://github.com/memes/lab-config/commit/3a8727fac48f182d554b5ad30d9e1829c4d58406))
* Networking update ([4e19006](https://github.com/memes/lab-config/commit/4e19006a2b3b9faa636a3aacc3888ae3100e75e1))
* Playbooks to install/remove kubernetes ([55fef21](https://github.com/memes/lab-config/commit/55fef21902ac62c832909afef0642192b8f2b5f2))
* Regenerate intermediate CA cert ([eff06b8](https://github.com/memes/lab-config/commit/eff06b8c83efd5643aab3419655fe8acca79fc69))
* Remove old/unsupported distros from PXE ([4e14a0b](https://github.com/memes/lab-config/commit/4e14a0b8f5de1499a1cd4c1aa2723d20fb8c2057))
* Update CRI-O to v1.27.0 and split Debian/RHEL ([b143adf](https://github.com/memes/lab-config/commit/b143adf3344d3bd0e4b4be990665208f3dc6a85d))
* Update existing roles after linting ([f4f74b8](https://github.com/memes/lab-config/commit/f4f74b89f5485bee88ce106f8ffb582f2d777a2b))
* Update networking role to better handle VLANs ([2a22b22](https://github.com/memes/lab-config/commit/2a22b2267278adb038e4c1b4fcd8c1626c40f066))
* Update networking/vlan role ([c9fdd08](https://github.com/memes/lab-config/commit/c9fdd0885668d1f8a917fa20683480276c918802))
* Update Vault PKI for kubernetes CA ([be30353](https://github.com/memes/lab-config/commit/be3035314cfa64fa9ff1c1524dbc61d00bdde399))
* Updated inventory, provisioning playbooks ([70450ba](https://github.com/memes/lab-config/commit/70450ba04bdccb864ab640b6e5928fb5879b807b))
* Updated shared role ([5a4792e](https://github.com/memes/lab-config/commit/5a4792e42a41744a67640cd7f65d041801c39693))
* Updated vault role to support IPv4 and IPv6 ([c7538f2](https://github.com/memes/lab-config/commit/c7538f2b2ed7ea9df56c6f9dc21da5c6f58229cb))
* use correct CIDR mask for internal VLAN ([0de13c7](https://github.com/memes/lab-config/commit/0de13c742b799b5d96571c6a02939e8673d00cd1))
