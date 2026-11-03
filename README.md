# adblock-hosts

Systemless `/system/etc/hosts` ad/tracker/phishing blocker for **KernelSU / Magisk**, built from the
[StevenBlack unified hosts](https://github.com/StevenBlack/hosts) list and **rebuilt automatically every week** by GitHub Actions.

- **Install once:** download `dist/adblock-hosts.zip`, install in KernelSU → reboot.
- **Updates:** KernelSU shows an **Update** button whenever a new build exists (via `updateJson`). One tap.
- **Revert:** toggle the module off in KernelSU.

Works on every app (hosts-level), no VPN, no battery cost. Verified on POCO F9 Ultra (HyperOS, KernelSU).

`./build.sh` rebuilds locally. `FORCE=1 ./build.sh` rebuilds even if the list is unchanged.
