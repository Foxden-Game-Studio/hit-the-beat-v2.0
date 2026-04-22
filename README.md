# Hit the Beat v2.0

## Switch language if needed:

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
| Hi-Hat 2 | Shift+D |
| Crash Cymbal 1 | R |
| Crash Cymbal 2 | I |
| Ride | L |

### MIDI Drum Kit
Supports standard MIDI pitch mapping for drum pads. Plug in any MIDI-compatible drum kit and play!

## Project Structure

```
hit-the-beat-v2.0/
├── scripts/                    # GDScript game logic
│   ├── game.gd                # Main game loop and scoring
│   ├── input_handler.gd       # Input device management
│   ├── device_*.gd            # Device-specific input handlers
│   ├── e_drum_kit.gd          # 3D drum kit controller
│   └── ...
├── scenes/                     # Godot scene files
│   ├── game.tscn              # Main gameplay scene
│   ├── main_menu.tscn         # Main menu
│   └── song_list.tscn         # Song selection screen
├── assets/                     # Graphics, models, shaders
│   ├── models/e-drum-kit.glb  # 3D drum kit model
│   ├── shaders/               # Custom shaders for effects
│   └── icons/                 # UI icons
├── songs/                      # Song data and audio
│   └── We_Will_Rock_You.json  # Song metadata and note timings
└── docs/                       # Research and implementation guides
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
- [ ] Complete note matching algorithm
- [ ] Leaderboard system
- [ ] Latency calibration system
- [ ] DIY drum kit support
- [ ] Touch screen input support
- [ ] Advanced visual effects
- [ ] Song editor tool
- [ ] Additional songs

## Credits

- Built with Godot Engine 4.6
- 3D drum kit model created in Blender
- Inspired by popular rhythm games (Guitar Hero, DDR, Beat Saber, osu!)

## Support

For issues, questions, or suggestions, please open an issue on GitHub.

---

**Status**: Active Development | **Version**: 1.0.0 | **Last Updated**: 2026
