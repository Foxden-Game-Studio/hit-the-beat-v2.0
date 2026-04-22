# Drum Mappings

## Input to Song Data Normalization

Maps all input device drum names to standardized song data format.

| Input Name | Normalized Name |
|---|---|
| Rack Tom 1 | tom 1 |
| Rack Tom 2 | tom 2 |
| Floor Tom 1 | tom 1 |
| Floor Tom 2 | tom 2 |
| Snare Drum | snare |
| Ride | ride |
| Crash Cymbal 1 | crash |
| Crash Cymbal 2 | crash |
| Hi-Hat_1 | hi-hat |
| Hi-Hat_2 | hi-hat |
| Bass Drum | bass |

## GDScript Dictionary

```gdscript
var drum_map = {
	"Rack Tom 1": "tom 1",
	"Rack Tom 2": "tom 2",
	"Floor Tom 1": "tom 1",
	"Floor Tom 2": "tom 2",
	"Snare Drum": "snare",
	"Ride": "ride",
	"Crash Cymbal 1": "crash",
	"Crash Cymbal 2": "crash",
	"Hi-Hat_1": "hi-hat",
	"Hi-Hat_2": "hi-hat",
	"Bass Drum": "bass",
}
```
