<div align="center">

```
      _/      _/  _/_/_/        _/_/_/_/    _/_/    _/      _/                      _/_/_/      _/_/    _/_/_/_/_/
     _/_/  _/_/  _/    _/      _/        _/    _/    _/  _/                        _/    _/  _/    _/      _/
    _/  _/  _/  _/_/_/        _/_/_/    _/    _/      _/          _/_/_/_/_/      _/    _/  _/    _/      _/
   _/      _/  _/    _/      _/        _/    _/    _/  _/                        _/    _/  _/    _/      _/
  _/      _/  _/    _/      _/          _/_/    _/      _/                      _/_/_/      _/_/        _/
```

### Mina personliga dotfiles för en minimal, tilingbaserad X11-miljö

![Platform](https://img.shields.io/badge/platform-Linux%20%2F%20Debian-informational?style=flat-square)
![Shell](https://img.shields.io/badge/shell-Bash-4EAA25?style=flat-square&logo=gnubash&logoColor=white)
![WM](https://img.shields.io/badge/window%20manager-sxwm-blueviolet?style=flat-square)
![Bar](https://img.shields.io/badge/status%20bar-sxbar-orange?style=flat-square)
![License](https://img.shields.io/badge/license-personal%20use-lightgrey?style=flat-square)

</div>

---

## Innehåll

- [Om](#om)
- [Funktioner](#funktioner)
- [Installation](#installation)
- [Struktur](#struktur)
- [Tangentbordsgenvägar (sxwm)](#tangentbordsgenvägar-sxwm)
- [Statusbar-moduler (sxbar)](#statusbar-moduler-sxbar)
- [Skärmbakgrund](#skärmbakgrund)

---

## Om

Det här är min personliga dotfiles-installation för en lättviktig, tangentbordsdriven
X11-skrivbordsmiljö byggd runt [`sxwm`](https://github.com/uint23/sxwm) (tiling window
manager), [`sxbar`](https://github.com/MrJensK/sxbar) (statusbar) och
[`dmenu`](https://github.com/MrJensK/dmenu) (programlauncher). Allt sätts upp automatiskt
via [`install.sh`](install.sh) — klona repot, kör skriptet, och du har en färdig miljö.

## Funktioner

| | |
|---|---|
| 🪟 | **sxwm** — tiling window manager, patchad för korrekt cursor-DPI |
| 📊 | **sxbar** — statusbar med klocka, datum, batteri, volym och CPU |
| 🚀 | **dmenu** — snabb programlauncher (`mod + p`) |
| 📶 | **bluetui** — Bluetooth-hantering direkt i terminalen |
| 🖥️ | **kitty** — GPU-accelererad terminal med GruvBox-tema och svepande cursor |
| 🔤 | **JetBrainsMono Nerd Font** — ikonstöd i bar och terminal |
| 🔊 | **PipeWire** — ljud (pipewire + pipewire-pulse + wireplumber) aktiverat automatiskt |
| 🔇 | Tyst installation — PC-speaker (`pcspkr`) och X-bell avstängda |
| 🌙 | Skärmsläckning/DPMS efter 5 min inaktivitet |
| ⌨️ | Svenskt tangentbord (`setxkbmap se`) |
| 🟢 | Autostart av X på TTY1 vid inloggning |

## Installation

```bash
git clone <detta repo>
cd dotfiles
./install.sh
```

Skriptet installerar systempaket, bygger och installerar `sxwm`, `sxbar`, `dmenu` och
`bluetui` från källkod, kopierar konfigfiler (med backup av befintliga), och frågar om
det får skriva `~/.xinitrc` åt dig.

## Struktur

```
dotfiles/
├── install.sh              # Huvudinstallationsskript
├── cursor-dpi-fix.patch    # Patch som appliceras på sxwm
├── BG/
│   └── j9huwdxo1zzg1.jpeg  # Skrivbordsbakgrund
└── config/
    ├── sxwmrc               # sxwm-konfiguration (tangentbord, layout, färger)
    ├── sxbarc               # sxbar-konfiguration (moduler, färger, ikoner)
    └── kitty/
        └── kitty.conf       # kitty-terminalkonfiguration
```

## Tangentbordsgenvägar (sxwm)

`mod` = <kbd>Super</kbd>

| Genväg | Åtgärd |
|---|---|
| `mod + Return` | Öppna kitty |
| `mod + b` | Öppna Firefox |
| `mod + p` | dmenu (programlauncher) |
| `mod + shift + q` | Stäng fönster |
| `mod + shift + e` | Avsluta sxwm |
| `mod + c` | Centrera fönster |
| `mod + m` | Toggle monocle-läge |
| `mod + j` / `mod + k` | Fokus nästa/föregående fönster |
| `mod + comma` / `mod + period` | Fokus föregående/nästa skärm |
| `mod + shift + j` / `mod + shift + k` | Flytta fönster i master/stack |
| `mod + l` / `mod + h` | Öka/minska master-area |
| `mod + Piltangenter` | Flytta fönster |
| `mod + shift + Piltangenter` | Ändra fönsterstorlek |
| `mod + equal` / `mod + minus` | Öka/minska gaps |
| `mod + space` | Toggle floating |
| `mod + shift + f` | Fullscreen |
| `mod + r` | Ladda om konfiguration |
| `mod + alt + [1-4]` | Skapa scratchpad |
| `mod + ctrl + [1-4]` | Toggle scratchpad |
| `mod + [1-9]` | Byt workspace |
| `mod + shift + [1-9]` | Flytta fönster till workspace |

## Statusbar-moduler (sxbar)

| Modul | Uppdateringsintervall | Färg |
|---|---|---|
| 🕐 Klocka | 1 s | `#50fa7b` |
| 📅 Datum | 60 s | `#8be9fd` |
| 🔋 Batteri | 30 s | `#ffb86c` |
| 🔊 Volym | 5 s | `#ff79c6` |
| ⚙️ CPU | 3 s | — |

## Skärmbakgrund

<div align="center">
<img src="BG/j9huwdxo1zzg1.jpeg" alt="Skrivbordsbakgrund" width="600">
</div>

Sätts automatiskt via `feh --bg-scale` i [`config/sxwmrc`](config/sxwmrc).

---

<div align="center">
<sub>Byggt för en snabb, minimal och tangentbordsdriven arbetsdag.</sub>
</div>
