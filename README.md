# Ultimate Doom Builder

## System requirements
- 2.4 GHz CPU or faster (multi-core recommended)
- Windows 7, 8, 10, or 11
- Graphics card with OpenGL 3.2 support

### Required software on Windows
- [Microsoft .Net Framework 4.7.2](https://dotnet.microsoft.com/download/dotnet-framework/net472)

## Building on Linux

__Note:__ this is experimental. None of the main developers are using Linux as a desktop OS, so you're pretty much on your own if you encounter any problems with running the application.

### Manual build

These instructions are for Debian-based distros and were tested with Ubuntu 24.04 LTS and Arch.

#### Dependency tiers

UDB has two dependency tiers on Linux. Start with the minimum and add the
full set only if you want the 3D rendering viewport.

**Minimum** – builds and runs the editor (2D map editing fully functional):

| Package | Purpose |
|---------|---------|
| `mono-complete` | Mono runtime + C# compiler |
| `msbuild` **or** `mono-xbuild` | MSBuild-compatible build tool |
| `make` | Drives the build |

**Full** – also enables the native 3D rendering library (`libBuilderNative.so`):

| Package | Purpose |
|---------|---------|
| `g++` | C++14 compiler for the native library |
| `libx11-dev` | X11 headers (OpenGL context) |
| `mesa-common-dev` | OpenGL headers |
| `libxfixes-dev` *(optional)* | Cursor hide/show in 3D view |

#### Install Mono

**Ubuntu – latest Mono 6.12 (build from source, recommended):**

The `mono-complete` package in Ubuntu's universe repository ships Mono 6.8,
which is functional but older. For the latest Mono 6.12 (last upstream release,
February 2024) build from the canonical GitHub source:

```bash
# Build dependencies
sudo apt install -y build-essential autoconf automake libtool \
  libglib2.0-dev cmake python3 gettext zlib1g-dev pkg-config

# Clone and build (~30–45 min)
git clone --depth=1 --recurse-submodules --shallow-submodules \
  https://github.com/mono/mono.git /tmp/mono-src
cd /tmp/mono-src
./autogen.sh --prefix=/usr/local --with-mcs-docs=no \
  --disable-nls --with-profile4_x=yes
make -j$(nproc)
sudo make install
mono --version   # 6.13.x
msbuild /version # 16.x
```

**Ubuntu – quick install (Mono 6.8 + xbuild, no extra repo needed):**

> The Makefile automatically falls back to `xbuild` when `msbuild` is absent,
> so this is the fastest path with zero extra repositories.

```bash
sudo apt install mono-complete mono-xbuild make
```

**Arch:**

```bash
sudo pacman -S mono mono-msbuild make
```

#### Install native rendering dependencies (optional – for 3D view)

**Ubuntu:**
```bash
# Required for native 3D rendering:
sudo apt install g++ libx11-dev mesa-common-dev
# Optional – enables cursor hide/show in 3D view:
sudo apt install libxfixes-dev
```

**Arch:**
```bash
sudo pacman -S base-devel
# libx11 libxfixes only needed on X11 display servers
```

#### Build and run

```bash
git clone https://github.com/UltimateDoomBuilder/UltimateDoomBuilder.git
cd UltimateDoomBuilder
make            # Release build  (use BUILDTYPE=Debug for a debug build)
cd Build && ./builder
```

If `g++` or the OpenGL/X11 dev headers are absent, `make` skips the native
library and prints a note — the editor still launches but the 3D viewport will
not be available.

### Flatpak build

The advantage of using Flatpak to build a package is that you do not need to install Mono directly into your system, since everything in the build process will be self-contained. This also means that this works on Linux distributions that do not have `msbuild` in their repository.

- To build UDB using Flatpak you need both **Flatpak** and **Flatpak Builder**. How they are installed depends on your distribution. For example on Debian-based distributions they can be installed using `sudo apt install flatpak flatpak-builder`. Check your distro's documentation for information on how to install them.
- Go to a directory of your choice and clone the repository (it'll automatically create an UltimateDoomBuilder directory in the current directory):
  ```
  git clone https://github.com/UltimateDoomBuilder/UltimateDoomBuilder.git
  ``` 
- Go to the cloned directory:
  ```
  cd UltimateDoomBuilder
  ```

- Build the Flatpak. This will also download all required dependencies:
  ```
  ./build_flatpak.sh
  ```

- This will create a file in the format `ultimatedoombuilder-<version>.flatpak` in the `Releases` directory. You can now install and run the Flatpak:

  ```
  flatpak install --user Releases/ultimatedoombuilder-<version>.flatpak
  flatpak run io.github.ultimatedoombuilder.ultimatedoombuilder
  ```
### Flatpak build using WSL2

You can also build the flatpak on Windows using WSL2.

#### Initial setup
- Create the instance. Requires entering a user name and password:
  ```powershell
  wsl --install Ubuntu-24.04 --name udb-flatpak-builder
  ```
- Install required Flatpak packages and clone the repository, then exit the insance. Requires entering the user password from the previous step:
  ```bash
  sudo apt update && sudo apt -y install flatpak flatpak-builder
  cd ~
  git clone https://github.com/UltimateDoomBuilder/UltimateDoomBuilder.git
  exit
  ```

#### Building the flatpak
- Update the repository and build the flatpak:
  ```powershell
  wsl --distribution udb-flatpak-builder --cd ~/UltimateDoomBuilder -- git pull `&`& ./build_flatpak.sh
  ```
- Get the flatpak from the UNC path `\\wsl.localhost\udb-flatpak-builder\home\$env:username\UltimateDoomBuilder\Releases`.
- Stop the instance (optional, it should shut itself down after some time):
  ```powershell
  wsl --terminate udb-flatpak-builder
  ```


# Links
- [Official thread link](https://forum.zdoom.org/viewtopic.php?f=232&t=66745)
- [Git builds at DRDTeam.org](https://devbuilds.drdteam.org/ultimatedoombuilder/) 

More detailed info can be found in the **editor documentation** (Refmanual.chm)

