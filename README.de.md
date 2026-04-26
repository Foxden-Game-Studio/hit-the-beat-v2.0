# Hit the Beat v2.0

Ändere die Sprache bei bedarf:

[🇬🇧 English](README.md) | [🇩🇪 Deutsch (aktuelle)](README.de.md)

Ein Rhythmusspiel, das in **Godot 4.6** entwickelt wurde, bei dem Spieler zusammen mit Schlagzeugmustern in Musikspuren spielen. Es verfügt über ein interaktives 3D-Schlagzeug, mehrere Eingabemethoden (Tastatur, MIDI) und ein Bewertungssystem, das auf Zeitgenauigkeit basiert.

## Funktionen

- 🥁 **Interaktives 3D-Schlagzeug** - 11 Schlagzeugpolster mit Shader-basiertem visuellen Feedback
- ⌨️ **Mehrere Eingabemethoden** - Tastatur, MIDI-Schlagzeuge, mit erweiterbarem Framework für Touch/DIY-Kits
- 🎵 **Rhythmusspiel-Mechaniken** - Präzise Treffererkennung mit Perfect/Great/Good/OK-Bewertungen
- 🎮 **Punkte- & Combo-System** - Echtzeit-Punktevergabe und Combo-Tracking
- 🌍 **Internationalisierung** - Englische und deutsche Sprachunterstützung
- 📱 **Mobile-optimiert** - Canvas-basiertes Rendering für mobile Kompatibilität

## Schnellstart

### Anforderungen
- PC (Windows/Linux) oder Android-Handy (aktuell mit externer Tastatur oder MIDI-Schlagzeug erforderlich)
- Godot Engine 4.6+ (Aktuell erforderlich. In Zukunft optional)
- Optional: MIDI-Schlagzeug für das beste Erlebnis

### Spiel ausführen

1. Repository klonen
2. In Godot 4.6 öffnen
3. Projekt ausführen (F5 oder Play-Taste)
4. Wählen Sie ein Lied und wählen Sie Ihr Eingabegerät
5. Befolgen Sie die Anweisungen auf dem Bildschirm und spielen Sie die Trommeln!

## Spielweise

### Punktevergabe
- **Perfect** (±40ms): 100 Punkte
- **Great** (±80ms): 80 Punkte  
- **Good** (±120ms): 50 Punkte
- **OK** (±180ms): 10 Punkte
- **Miss** (>180ms): 0 Punkte

### Combo
- Erhöht sich bei Perfect- und Great-Treffern
- Setzt sich bei Good-, OK- oder Miss-Treffern zurück

## Eingabegeräte

### Tastatur
| Schlagzeug | Taste |
|---|---|
| Bassdrum | Leertaste |
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

### MIDI-Schlagzeug
Unterstützt Standard-MIDI-Tonzuordnung für Schlagzeugpolster. Schließen Sie ein beliebiges MIDI-kompatibles Schlagzeug an und spielen Sie!

## Projektstruktur

```
hit-the-beat-v2.0/
├── scripts/                    # GDScript-Spiellogik
│   ├── game.gd                # Hauptspielschleife und Bewertung
│   ├── input_handler.gd       # Eingabegeräteverwaltung
│   ├── device_*.gd            # Gerätespezifische Eingabe-Handler
│   ├── e_drum_kit.gd          # 3D-Schlagzeug-Controller
│   └── ...
├── scenes/                     # Godot-Szenendateien
│   ├── game.tscn              # Hauptspielszene
│   ├── main_menu.tscn         # Hauptmenü
│   └── song_list.tscn         # Liedauswahlbildschirm
├── assets/                     # Grafiken, Modelle, Shader
│   ├── models/e-drum-kit.glb  # 3D-Schlagzeugmodell
│   ├── shaders/               # Benutzerdefinierte Shader für Effekte
│   └── icons/                 # UI-Symbole
├── songs/                      # Lied- und Audiodaten
│   └── We_Will_Rock_You.json  # Liedmetadaten und Note-Timings
└── docs/                       # Forschungs- und Implementierungsleitfäden
```

## Liedformat

Lieder sind im JSON-Format definiert:

```json
{
  "song_name": "Liedtitel",
  "difficulty": "easy",
  "audio_file": "res://songs/Song.mp3",
  "timestamps": [
    {"time": 0.197, "type": "tom 1"},
    {"time": 0.566, "type": "tom 2"},
    ...
  ]
}
```

Fügen Sie neue Lieder hinzu, indem Sie eine JSON-Datei im Verzeichnis `songs/` erstellen.

## Technologien

- **Engine**: Godot Engine 4.6
- **Sprache**: GDScript
- **Rendering**: Mobile (Canvas Items)
- **Physik**: Jolt Physics
- **Audio**: AudioStreamPlayer3D
- **3D-Modelle**: Blender (GLB-Export)

## Entwicklung

### Architektur

Das Spiel folgt einer modularen Architektur:

```
Eingabegeräte → Eingabe-Handler → Spiellogik → Punkte/UI
                                    ↓
                              3D-Visualisierung
```

### Wichtige Systeme

- **Eingabesystem**: Abstrakte Geräteebene mit Unterstützung für Tastatur, MIDI und erweiterbar für benutzerdefinierte Geräte
- **Spielschleife**: Per-Frame-Eingabeverarbeitung mit Zeitstempel-basierter Notenabstimmung
- **Bewertung**: Trefferbewertungsevaluierung basierend auf Timing-Delta
- **UI-System**: Overlay-basierte Benutzeroberfläche für Punkte, Combo und Menü-Steuerelemente
- **3D-Visuals**: Shader-basiertes Feedback-System mit interaktiven Schlagzeugpolstern

## Roadmap

- [x] Kerngame-Architektur und Szenenverwaltung
- [x] Multi-Input-Geräte-Framework
- [x] 3D-Schlagzeug-Visualisierung
- [x] Grundlegendes Bewertungssystem
- [ ] Vollständiger Note-Matching-Algorithmus
- [ ] Bestenlisten-System
- [ ] Latenz-Kalibrierungssystem
- [ ] DIY-Schlagzeug-Unterstützung
- [ ] Touch-Screen-Eingabe-Unterstützung
- [ ] Fortgeschrittene visuelle Effekte
- [ ] Lied-Editor-Tool
- [ ] Zusätzliche Lieder

## Credits

- Gebaut mit Godot Engine 4.6
- 3D-Schlagzeugmodell in Blender erstellt
- Inspiriert von beliebten Rhythmusspiele (Guitar Hero, DDR, Beat Saber, osu!)

## Unterstützung

Bei Problemen, Fragen oder Vorschlägen bitte ein Problem auf GitHub öffnen.

---

**Status**: Aktive Entwicklung | **Version**: 1.0.0 | **Zuletzt aktualisiert**: 2026
