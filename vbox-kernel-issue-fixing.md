Here is the troubleshooting guide formatted cleanly as a Markdown file. You can copy the code block below and save it as something like `virtualbox-dkms-fix.md` for your GitHub repository.

```markdown
# VirtualBox Driver Mismatch Troubleshooting Guide (Arch / EndeavourOS)

A guide to resolving the `VERR_VM_DRIVER_VERSION_MISMATCH` (rc=-1912) error on Arch Linux-based systems. This occurs when the VirtualBox application version and the loaded kernel modules fall out of sync after a system update.

---

## Quick Fix: Reload Kernel Modules
If the kernel modules are compiled but the old ones are simply stuck in your active RAM session, force-reload them:

```bash
# Unload current VirtualBox modules
sudo rmmod vboxnetadp vboxnetflt vboxdrv

# Reload the fresh modules
sudo modprobe vboxdrv vboxnetadp vboxnetflt

```

*Note: If `rmmod` throws an error about `vboxpci`, ignore it. The `vboxpci` module is obsolete and removed in newer VirtualBox releases.*

---

## Permanent Fix: Switch to DKMS

The most robust solution to prevent this error from happening during future kernel updates is to switch from pre-compiled host modules to Dynamic Kernel Module Support (DKMS). This ensures modules are automatically rebuilt every time your kernel updates.

### 1. Install Linux Headers and DKMS Host Modules

Run the following command. When prompted to remove `virtualbox-host-modules-arch` due to a conflict, choose **Y** (Yes).

```bash
sudo pacman -S linux-headers virtualbox-host-dkms

```

### 2. Verify or Force Manual Compilation (Optional)

Pacman usually handles compilation automatically via a post-transaction hook. If you ever need to force DKMS to compile modules manually for your running kernel, use:

```bash
sudo dkms autoinstall

```

### 3. Reboot the System

For the kernel to fully hook into the newly compiled modules cleanly, perform a system restart:

```bash
sudo reboot

```

---

## Why This Happens

* **The Problem:** The standard `virtualbox-host-modules-arch` package relies on the Arch repository maintainers updating the modules in lockstep with the core kernel. If you update your system and don't reboot, or if a minor mismatch occurs between the repo packages, the driver mismatch triggers.
* **The Solution:** `virtualbox-host-dkms` builds the VirtualBox drivers locally using your machine's exact `linux-headers`, ensuring a perfect structural match every single time.

```

```
