# ESP FOR UNKNOWN THREAT MOBILE

**Full-featured ESP for the game Unknown Threat, optimized for mobile devices.**

[![Lua](https://img.shields.io/badge/Lua-100%25-blue?style=flat-square&logo=lua)](https://www.lua.org/)
[![Roblox](https://img.shields.io/badge/Roblox-ESP-red?style=flat-square&logo=roblox)](https://www.roblox.com/)

---

## 📌 Description

This script provides advanced ESP (Extra Sensory Perception) for the **Unknown Threat** game on **Roblox**. It is specifically adapted for **mobile devices** (phones and tablets) but works perfectly on PC as well.

All settings are **automatically saved** inside the game world (in a folder named `ESP_Settings` within `workspace`) and loaded on the next run.

---

## 🎯 Features

### ESP (Extra Sensory Perception)

| Feature | Description |
|---------|-------------|
| **Box ESP** | Displays a box around the player (Corner or Full style) |
| **Skeleton ESP** | Shows the player's skeleton |
| **Name ESP** | Shows the player's name above their head |
| **Health Bar** | Health bar with optional numeric value |
| **Tracer ESP** | Line from a chosen origin (Bottom, Top, Mouse, Center) to the player |
| **Head Point** | A dot above the player's head |
| **Team Check** | Disables ESP for teammates (based on in-game roles) |
| **Wall Check** | Hides ESP behind walls (does not work through obstacles) |
| **Max Distance** | Adjust the maximum rendering distance for ESP |
| **Rainbow Mode** | Dynamic color cycling for all players |

### 🎨 Role Colors Customization

You can customize colors for each role:

- **Seeker / Killer** – Red
- **Hider** – Yellow
- **Innocent** – Green
- **Traitor** – Purple
- **Police / SWAT / Sheriff** – Blue
- **Juggernaut** – Orange
- **No Role** – White
- **Unknown** – Grey

---

## 📱 Mobile Optimization

The script is fully optimized for mobile:

- ✅ Adaptive GUI size (80% width, 60% height of the screen)
- ✅ Removed the minimize key (does not work on touchscreens)
- ✅ Automatically switches the "Mouse" tracer origin to "Center" when using touch controls

---

## 🚀 Installation & Usage

### Method 1: Using loadstring (recommended)

Copy and paste this code into any Lua executor (e.g., Synapse X, Krnl, Fluxus, Arceus X, etc.):

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/great-lua/ESP-FOR-UNKNOWN-THREAT-MOBILE/main/esp.lua"))()
```

Method 2: Manual
Download the esp.lua file.

Paste its contents into your executor.

Run the script.

🎮 GUI Controls
After running the script, a graphical menu will appear with the following tabs:

Tab	Description
Main	Toggle ESP features on/off
Visuals	Customize appearance (line thickness, box style, sizes)
Settings	General options (max distance, rainbow mode, role colors)
Config	Save/load profiles, unload the script
🛠 Requirements
Roblox with Unknown Threat installed.

Any Lua executor that supports game:HttpGet() and the Drawing library.

📂 Settings Storage
Settings are automatically stored in a folder named ESP_Settings inside workspace. On the next run, they are loaded automatically.

🤝 Contributing
If you'd like to improve the script or add new features:

Fork the repository

Make your changes

Submit a Pull Request

📜 License
This project is licensed under the MIT License. See the LICENSE file for details.

🙏 Credits
Fluent – GUI library

SaveManager – Save management

Great – Development and support

📞 Contact
Discord: https://discord.gg/qR7ABr7f

GitHub: great-lua

⭐ If you like this script, don't forget to star the repository! ⭐

text

---

## 🔗 Loadstring

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/great-lua/ESP-FOR-UNKNOWN-THREAT-MOBILE/main/esp.lua"))()
```
Just copy the README content into your README.md file on GitHub and use the loadstring for quick execution. Let me know if you need any adjustments!
