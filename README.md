<div align="center">

![Screenshot](showcase/image.png) 
<br>
<br>

# NeKoRoSHELL DLux 

![GitHub Repo stars](https://img.shields.io/github/stars/NeKoRoSYS/NeKoRoSHELL-DLux-Shell?style=for-the-badge&color=%23FFD700)
 ![GitHub Release](https://img.shields.io/github/v/release/NeKoRoSYS/NeKoRoSHELL-DLux-Shell?display_name=tag&style=for-the-badge) ![Size](https://img.shields.io/github/repo-size/NeKoRoSYS/NeKoRoSHELL-DLux-Shell?style=for-the-badge) ![GitHub last commit](https://img.shields.io/github/last-commit/NeKoRoSYS/NeKoRoSHELL-DLux-Shell?style=for-the-badge) ![GitHub contributors](https://img.shields.io/github/contributors/NeKoRoSYS/NeKoRoSHELL-DLux-Shell?style=for-the-badge) ![Discord](https://img.shields.io/discord/774473787394752532?style=for-the-badge&label=Discord&color=%235865F2)
 <br>
 <br>

</div>

The best way to say "I use Linux btw 🤓" is if your desktop environment looks sleek and suave.

Powered by Hyprland and Quickshell, **NeKoRoSHELL DLux** aims strives to achieve what its predecessor could not; all while maintaining core philosophies and robustness.

**This repo only contain the files for `.config/quickshell/`. If you want the actual dotfiles, [check them out here](https://github.io/NeKoRoSYS/NeKoRoSHELL-DLux-Shell)**
<br>
<br>

<div align="center">
 
| 📌 **Table of Contents** |
| :---: |
| 🚀 [Features](#features) |
| 🔗 [Dependencies](#dependencies) |

</div>
<br>

## Features

NeKoRoSHELL DLux focuses on simplicity and modularity.
<br>

The following are what NeKoRoSHELL DLux currently offers:
- **Portable and Distro-agnostic**
  - Use NeKoRoSHELL DLux in any **supported** distro!
  - Init-agnostic.
  - XDG-compliant.
  - Features an advanced installer script.
    - Use `git clone https://github.com/NeKoRoSYS/NeKoRoSHELL DLux`
    - Then `cd NeKoRoSHELL DLux`
    - and finally, `bash install.sh` to install the dotfiles.
    - `install.sh` assumes you already have `git` and a distro-specific `g++` compiler.
    - `install.sh` requires you to have `cargo`, `paru`/`yay`, `go`, and `flatpak`.
    - You can freely customize `flatpak.txt` and `pkglist-DISTRO.txt` before running `install.sh`.
    - **The installer is safe.** It backs up your pre-existing .config folders. (If you have any)
    - The installer automatically handles assigning your monitors at `~/.config/hypr/configs/monitors.conf/` and replaces every occurence of `/home/nekorosys/` with your username for your own convenience.
    - SOME distros don't have hyprland or other dependencies on their package manager's repository and you may have to manually build them from source via script or something else.

- **NeKoRoSHELL DLux as a Service**
  - Update your copy of NeKoRoSHELL DLux simply by running the `NeKoRoSHELL DLux update` command on your terminal.
  - Uses Vim or your preferred text editor to assist in reviewing file updates and gives the ability to overwrite, keep, and merge.
<br>

![Screenshot](showcase/image-5.png) 
<br>
<br>
<br>
![Screenshot](showcase/image-3.png) 
<br>
<br>
<br>
![Screenshot](showcase/image-1.png) 
<br>
<br>
<br>
![Screenshot](showcase/image-2.png) 
<br>
<br>

### Roadmap

NeKoRoSHELL DLux is currently being developed by one person (*cough* [CONTRIBUTING](https://github.com/NeKoRoSYS/NeKoRoSHELL-DLux-Shell/tree/main?tab=contributing-ov-file#) *cough*) and is constantly under rigorous quality assurance for improvement. We always aim to keep a "no-break" promise for every update so that you can safely update to later versions without expecting any breakages.

<br>
<div align="center">

| 📋 **TODO** | **STATUS** |
| :---: | :---: |
| Improve base theme | 🛠 |
| Port all necessary bash scripts into native QML modules/functionality | ⏳ |

</div>
<br>

## Dependencies

> [!CAUTION]
> **HARDWARE SPECIFIC CONFIGURATION**<br>
>
> Some environment variables and params at `~/.config/hypr/configs/environment.conf/` and `~/.config/hypr/scripts/set-wallpaper.sh/` (also check the `check-video.sh` script, `mpvpaper` uses a "hwdec=nvdec" param) **require an NVIDIA graphics card**. Although it may be generally safe to leave it as is upon installing to a machine without such GPU, I recommend commenting it out or replacing it with a variable that goes according to your GPU.

> [!WARNING]
> **SOFTWARE SPECIFIC CONFIGURATION**<br>
>
> This project of mine was originally built only for Arch Linux but is now capable of claiming itself to be Distro-agnostic. However, **installation of this repo in other Linux Distros aside from Arch is more or less UNTESTED.** Please verify using `nano` or your preferred text editor if your distro supports the packages listed at `pkglist-DISTRO.txt` or if the packages are named correctly.
>
> The installation system that I implemented can be improved. If you're willing to help, please make a pull request. Your contributions are welcome and will be appreciated! :D

- `NeKoRoSHELL DLux update` may use Vim to compare, overwrite, or merge files when updating.
- Requires `quickshell-git` to function.
<br>

## Star History
<br>

<div align="center">
<a href="https://www.star-history.com/#nekorosys/NeKoRoSHELL-DLux-Shell&type=date&legend=bottom-right">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=nekorosys/NeKoRoSHELL-DLux-Shell&type=date&theme=dark&legend=bottom-right" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=nekorosys/NeKoRoSHELL-DLux-Shell&type=date&legend=bottom-right" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=nekorosys/NeKoRoSHELL-DLux-Shell&type=date&legend=bottom-right" />
 </picture>
</a>
</div>
