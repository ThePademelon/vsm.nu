# vsm.nu

Nushell module for viewing and enabling runit services. In this context, "enable" means symlinking the service directory into the current runsvdir (this is the nomenclature used by the Void Linux manual).

## Examples

Run `vsm list` to fetch the full list of services (inlcuding services you haven't enabled yet). The output is a list of records which you can perform everyday Nushell filtering on.

<img width="789" height="392" alt="image" src="https://github.com/user-attachments/assets/ad6f0ab6-cbd8-47a6-935e-142c932864c3" />

## Quickstart
```nushell
git clone https://github.com/ThePademelon/vsm.nu; cd vsm.nu
use vsm.nu *
```
To start Nushell with these commands included, add this to your config.nu
```nushell
use <path to this repo>/vsm.nu *
```
