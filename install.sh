#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SXWM_REPO="https://github.com/uint23/sxwm.git"
SXBAR_REPO="https://github.com/MrJensK/sxbar.git"
BUILD_DIR="/tmp/sxwm-sxbar-build"

echo "==> Installerar beroenden..."
sudo apt-get update -qq
sudo apt-get install -y \
    git \
    make \
    gcc \
    libx11-dev \
    libxinerama-dev \
    libxrandr-dev \
    libxcursor-dev \
    xorg \
    xinit \
    firefox-esr \
    dmenu \
    kitty

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

echo "==> Kopierar konfigfiler..."
mkdir -p "$HOME/.config/kitty"

copy_config() {
    local src="$SCRIPT_DIR/config/$1"
    local dst="$HOME/.config/$1"
    if [ -f "$dst" ]; then
        cp "$dst" "$dst.bak"
        echo "    $1 -> backup sparad: ~/.config/$1.bak"
    fi
    cp "$src" "$dst"
    echo "    $1 -> ~/.config/$1"
}

copy_config sxwmrc
copy_config sxbarc
copy_config kitty/kitty.conf

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

# Svenskt tangentbord
setxkbmap se

# Jens SXbar
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

echo ""
echo "Installation slutförd!"
