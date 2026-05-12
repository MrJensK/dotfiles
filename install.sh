#!/bin/bash
set -e

SXWM_REPO="https://github.com/uint23/sxwm.git"
SXBAR_REPO="https://github.com/MrJensK/sxbar.git"
BUILD_DIR="/tmp/sxwm-sxbar-build"

echo "==> Installing dependencies..."
sudo apt-get update -qq
sudo apt-get install -y \
    git \
    make \
    gcc \
    libx11-dev \
    libxinerama-dev \
    libxcursor-dev \
    xorg \
    xinit
    \

mkdir -p "$BUILD_DIR"
cd "$BUILD_DIR"

echo "==> Cloning sxwm..."
rm -rf sxwm
git clone --depth=1 "$SXWM_REPO" sxwm

echo "==> Building and installing sxwm..."
cd sxwm
make
sudo make install
cd "$BUILD_DIR"

echo "==> Cloning sxbar..."
rm -rf sxbar
git clone --depth=1 "$SXBAR_REPO" sxbar

echo "==> Building and installing sxbar..."
cd sxbar
make
sudo make install
cd "$BUILD_DIR"

echo "==> Copying config files..."
mkdir -p "$HOME/.config"

if [ ! -f "$HOME/.config/sxwmrc" ]; then
    cp "$BUILD_DIR/sxwm/default_sxwmrc" "$HOME/.config/sxwmrc"
    echo "    sxwmrc  -> ~/.config/sxwmrc"
else
    echo "    sxwmrc  already exists, skipping (backup: ~/.config/sxwmrc.bak)"
    cp "$HOME/.config/sxwmrc" "$HOME/.config/sxwmrc.bak"
fi

if [ ! -f "$HOME/.config/sxbarc" ]; then
    cp "$BUILD_DIR/sxbar/default_sxbarc" "$HOME/.config/sxbarc"
    echo "    sxbarc  -> ~/.config/sxbarc"
else
    echo "    sxbarc  already exists, skipping (backup: ~/.config/sxbarc.bak)"
    cp "$HOME/.config/sxbarc" "$HOME/.config/sxbarc.bak"
fi

echo ""
echo "==> Konfigurering av ~/.xinitrc"
echo ""

# Fråga om rensning
read -p "Vill du rensa gammal konfiguration från ~/.xinitrc? (j/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Jj]$ ]]; then
    echo "Rensar gammal konfiguration..."
    # Backa upp befintlig xinitrc
    if [ -f "$HOME/.xinitrc" ]; then
        cp "$HOME/.xinitrc" "$HOME/.xinitrc.bak"
        echo "    Backup skapad: ~/.xinitrc.bak"
    fi
    # Skapa ny xinitrc
    cat > "$HOME/.xinitrc" << 'EOF'
#!/bin/bash
# Stänga av skärmarna efter 5 min
xset s 300 300
xset dpms 300 300 300

# Svenskt tangentbord
setxkbmap se

# Jens SXbar
sxbar &
exec sxwm
EOF
    chmod +x "$HOME/.xinitrc"
    echo "    ~/.xinitrc skapad med nya inställningar"
else
    echo "Lägg manuellt till i ~/.xinitrc:"
    echo ""
    echo "# Stänga av skärmarna efter 5 min"
    echo "xset s 300 300"
    echo "xset dpms 300 300 300"
    echo "# Svenskt tangentbord"
    echo "setxkbmap se"
    echo "# Jens SXbar"
    echo "sxbar &"
    echo "exec sxwm"
fi

echo ""
echo "Installation slutförd!"

