#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SXWM_REPO="https://github.com/uint23/sxwm.git"
SXBAR_REPO="https://github.com/MrJensK/sxbar.git"
DMENU_REPO="https://github.com/MrJensK/dmenu.git"
BUILD_DIR="/tmp/sxwm-sxbar-build"

echo "==> Installerar beroenden..."
sudo apt-get update -qq
sudo apt-get install -y \
    git \
    make \
    gcc \
    build-essential \
    pkg-config \
    libx11-dev \
    libxinerama-dev \
    libxrandr-dev \
    libxcursor-dev \
    libxft-dev \
    libfontconfig1-dev \
    xorg \
    xinit \
    firefox-esr \
    kitty \
    pipewire-audio \
    alsa-utils \
    bluez \
    patch \
    wget \
    curl \
    unzip \
    fontconfig \

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "==> Klonar sxwm..."
rm -rf sxwm
git clone --depth=1 "$SXWM_REPO" sxwm

echo "==> Applicerar sxwm-patch..."
cd sxwm
patch -p1 < "$SCRIPT_DIR/cursor-dpi-fix.patch"

echo "==> Bygger och installerar sxwm..."
make
sudo make install
cd "$BUILD_DIR"

echo "==> Klonar sxbar..."
rm -rf sxbar
git clone --depth=1 "$SXBAR_REPO" sxbar

echo "==> Bygger och installerar sxbar..."
cd sxbar
make
sudo make install
cd "$BUILD_DIR"

echo "==> Klonar dmenu..."
rm -rf dmenu
git clone --depth=1 "$DMENU_REPO" dmenu

echo "==> Bygger och installerar dmenu..."
cd dmenu
make
sudo make install
cd "$BUILD_DIR"

echo "==> Kopierar konfigfiler..."
mkdir -p "$HOME/.config/kitty" "$HOME/.config/sxbar"

copy_config() {
    local src="$SCRIPT_DIR/config/$1"
    local dst="$HOME/.config/$2"
    mkdir -p "$(dirname "$dst")"
    if [ -f "$dst" ]; then
        cp "$dst" "$dst.bak"
        echo "    $2 -> backup sparad: ~/.config/$2.bak"
    fi
    cp "$src" "$dst"
    echo "    $2 -> ~/.config/$2"
}

copy_config sxwmrc sxwmrc
copy_config sxbarc sxbar/sxbarc
copy_config kitty/kitty.conf kitty/kitty.conf

echo "==> Kopierar skrivbordsbakgrund..."
mkdir -p "$HOME/BG"
cp -n "$SCRIPT_DIR/BG/"* "$HOME/BG/"
echo "    BG/ -> ~/BG/"

echo ""
echo "==> Konfigurering av ~/.xinitrc"
echo ""

read -p "Vill du skriva över ~/.xinitrc? (j/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Jj]$ ]]; then
    if [ -f "$HOME/.xinitrc" ]; then
        cp "$HOME/.xinitrc" "$HOME/.xinitrc.bak"
        echo "    Backup skapad: ~/.xinitrc.bak"
    fi
    cat > "$HOME/.xinitrc" << 'EOF'
#!/bin/bash
# Stänga av skärmarna efter 5 min
xset s 300 300
xset dpms 300 300 300

# Stäng av pip-ljudet (bell)
xset b off

# Svenskt tangentbord
setxkbmap se

exec sxwm
EOF
    chmod +x "$HOME/.xinitrc"
    echo "    ~/.xinitrc skapad"
else
    echo "Lägg manuellt till i ~/.xinitrc:"
    echo ""
    echo "  xset s 300 300"
    echo "  xset dpms 300 300 300"
    echo "  setxkbmap se"
    echo "  exec sxwm"
fi

echo "==> Stänger av PC-speaker beep..."
echo "blacklist pcspkr" | sudo tee /etc/modprobe.d/nobeep.conf > /dev/null
sudo rmmod pcspkr 2>/dev/null || true

echo "==> Tar bort ev. gammal rustc/cargo från apt (Debian har ofta för gammal version)..."
RUST_APT_PKGS=$(dpkg-query -W -f='${Package}\n' 'rustc' 'cargo' 'libstd-rust-dev' 'rust-llvm' 'libstd-rust-*' 2>/dev/null || true)
if [ -n "$RUST_APT_PKGS" ]; then
    sudo apt-get purge -y $RUST_APT_PKGS
    sudo apt-get autoremove --purge -y
fi

echo "==> Installerar rustup..."
if ! command -v rustup >/dev/null 2>&1 && [ ! -x "$HOME/.cargo/bin/rustup" ]; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
# shellcheck disable=SC1091
source "$HOME/.cargo/env"

echo "==> Bygger och installerar bluetui..."
rm -rf "$BUILD_DIR/bluetui"
git clone --depth=1 https://github.com/pythops/bluetui "$BUILD_DIR/bluetui"
cd "$BUILD_DIR/bluetui"
cargo build --release
sudo cp target/release/bluetui /usr/local/bin/
cd "$BUILD_DIR"

echo "==> Installerar JetBrainsMono Nerd Font..."
FONT_DIR="$HOME/.local/share/fonts/JetBrainsMono"
mkdir -p "$FONT_DIR"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
wget -q --show-progress -O /tmp/JetBrainsMono.zip "$FONT_URL"
unzip -o /tmp/JetBrainsMono.zip -d "$FONT_DIR" '*.ttf'
rm /tmp/JetBrainsMono.zip
fc-cache -f
echo "    JetBrainsMono Nerd Font installerad"

echo "==> Konfigurerar autostart av X på TTY1..."
BASH_PROFILE="$HOME/.bash_profile"
AUTOSTART='if [ -z "$DISPLAY" ] && [ "$(tty)" = "/dev/tty1" ]; then exec startx; fi'
if grep -qF 'exec startx' "$BASH_PROFILE" 2>/dev/null; then
    echo "    ~/.bash_profile redan konfigurerad, hoppar över"
else
    echo "" >> "$BASH_PROFILE"
    echo "$AUTOSTART" >> "$BASH_PROFILE"
    echo "    ~/.bash_profile uppdaterad"
fi

echo "==> Aktiverar PipeWire..."
systemctl --user enable --now pipewire pipewire-pulse wireplumber

echo ""
echo "Installation slutförd!"
