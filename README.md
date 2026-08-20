# Note on the 20.08.2026
This repo has been temporarily archived 

# Hit the Beat v2.0

Switch language if needed:

[🇬🇧 English (current)](README.md) | [🇩🇪 Deutsch](README.de.md)

A rhythm game built in **Godot 4.6** where players play along with drum patterns in musical tracks. Features a 3D interactive drum kit, multiple input methods (keyboard, MIDI), and a scoring system based on timing accuracy.

## Features

- 🥁 **Interactive 3D Drum Kit** - 11 drum pads with shader-based visual feedback
- ⌨️ **Multiple Input Methods** - Keyboard, MIDI drum kits, with extensible framework for touch/DIY kits
- 🎵 **Rhythm Game Mechanics** - Precise hit detection with Perfect/Great/Good/OK ratings
- 🎮 **Score & Combo System** - Real-time scoring and combo tracking
- 🌍 **Internationalization** - English and German language support
- 📱 **Mobile-Optimized** - Canvas-based rendering for mobile compatibility

## Quick Start

### Requirements
- PC (Windows/Linux) or Android Phone (needs external Keyboard or a MIDI drum kit at the time)
- Godot Engine 4.6+ (Required at the time. Optional in the future)
- Optional: MIDI drum kit for best experience

### Running the Game

1. Clone the repository
2. Open in Godot 4.6
3. Run the project (F5 or Play button)
4. Select a song and choose your input device
5. Follow the on-screen prompts and hit the drums!

## Gameplay

### Scoring
- **Perfect** (±40ms): 100 points
- **Great** (±80ms): 80 points  
- **Good** (±120ms): 50 points
- **OK** (±180ms): 10 points
- **Miss** (>180ms): 0 points

### Combo
- Increases on Perfect and Great hits
- Resets on Good, OK, or Miss hits

## Input Devices

### Keyboard
| Drum | Key |
|------|-----|
| Bass Drum | Spacebar |
| Snare | F |
| Rack Tom 1 | G |
| Rack Tom 2 | J |
| Floor Tom 1 | K |
| Floor Tom 2 | M |
| Hi-Hat 1 | D |
| Hi-Hat 2 | S |
| Crash Cymbal 1 | R |
| Crash Cymbal 2 | I |
| Ride | L |

### MIDI Drum Kit
Supports standard MIDI pitch mapping for drum pads. Plug in any MIDI-compatible drum kit and play!

### DIY Drum Kit
You can connect a custom Arduino/ESP32 based drum kit!
1. Start the `Code_PC_app.py` script to read the serial data from your microcontroller.
2. Select the correct COM port for your ESP32 in the python app popup.
3. Open "Hit the Beat" and go to the Settings menu.
4. Select the **DIY Drum Kit** as your input device.
The python script will automatically send UDP packets to the game on port `5005` whenever you hit a drum pad.

## Project Structure

```
hit-the-beat-v2.0/
├── assets/                     # Graphics, icons, and translations
│   ├── graphics/              # 2D graphics and backgrounds
│   ├── icons/                 # UI icons
│   └── translations/          # Translation files (CSV, translation)
├── core/                       # Core systems and global logic
│   ├── autoloads/             # Global variables and helper functions
│   ├── input/                 # Input handling framework
│   │   └── devices/           # Keyboard, MIDI, touch, and DIY device handlers
│   └── ui/                    # Reusable UI components
├── data/                       # Game content
│   └── songs/                 # Song metadata (.json) and audio files
├── features/                   # Main game features and scenes
│   ├── drum_kit/              # 3D drum kit model, logic, and shaders
│   ├── editor/                # Song editor tool
│   ├── game/                  # Gameplay loop, UI, and song selection
│   ├── main_menu/             # Main menu interface
│   └── settings/              # Settings menu
└── source/                     # Original source files (Blend files, models)
```

## Song Format

Songs are defined in JSON format:

```json
{
  "song_name": "Song Title",
  "difficulty": "easy",
  "audio_file": "res://songs/Song.mp3",
  "timestamps": [
    {"time": 0.197, "type": "tom 1"},
    {"time": 0.566, "type": "tom 2"},
    ...
  ]
}
```

Add new songs by creating a JSON file in the `songs/` directory.

## Technologies

- **Engine**: Godot Engine 4.6
- **Language**: GDScript
- **Rendering**: Mobile (Canvas Items)
- **Physics**: Jolt Physics
- **Audio**: AudioStreamPlayer3D
- **3D Models**: Blender (GLB export)

## Development

### Architecture

The game follows a modular architecture:

```
Input Devices → Input Handler → Game Logic → Score/UI
                                   ↓
                              3D Visualization
```

### Key Systems

- **Input System**: Abstracted device layer supporting keyboard, MIDI, and extensible for custom devices
- **Game Loop**: Per-frame input processing with timestamped note matching
- **Scoring**: Hit quality evaluation based on timing delta
- **UI System**: Overlay-based UI for score, combo, and menu controls
- **3D Visuals**: Shader-based feedback system with interactive drum pads

## Roadmap

- [x] Core game architecture and scene management
- [x] Multi-input device framework
- [x] 3D drum kit visualization
- [x] Basic scoring system
- [X] Complete note matching algorithm
- [x] Leaderboard system
- [ ] Latency calibration system
- [x] DIY drum kit support
- [ ] Touch screen input support
- [ ] Advanced visual effects
- [x] Song editor tool
- [ ] Additional songs

## Credits

- Built with Godot Engine 4.6
- 3D drum kit model created in Blender
- Inspired by popular rhythm games (Guitar Hero, DDR, Beat Saber, osu!)

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

**Status**: Active Development | **Version**: 1.0.0 | **Last Updated**: 2026
