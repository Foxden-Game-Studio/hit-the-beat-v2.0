# Hit the Beat v2.0: Implementation Recommendations

## Based on Your Current Code Analysis

After reviewing your project structure (`game.gd`, input handlers, song format), here are specific recommendations for implementing note comparison algorithms.

---

## Your Current Architecture

### Current State (from `game.gd`):
```gdscript
var timestamps = []        # Loaded from JSON
var queued_inputs = []     # Stores {"type": String, "time": float}

func _process(_delta: float) -> void:
    # Currently empty - this is where comparison logic goes
    
func _on_input(type: String):
    var current_time = audio_player.get_playback_position()
    queued_inputs.push_back({"type": type, "time": current_time})
```

**Assessment:** You have the basic structure in place. The comparison loop is missing from `_process()`.

---

## Recommended Implementation (Phase 1: MVP)

### Step 1: Add Sorting to _ready()

```gdscript
func _ready() -> void:
    setup_input_device()
    
    var song_file = FileAccess.get_file_as_string(song)
    if not song_file:
        get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
        return
    
    var song_data = JSON.parse_string(song_file)
    timestamps = song_data["timestamps"]
    
    # NEW: Sort timestamps by time (critical for binary search)
    timestamps.sort_custom(func(a, b): return a.time < b.time)
    
    # NEW: Add metadata to each timestamp for tracking
    for i in range(timestamps.size()):
        timestamps[i]["matched"] = false
        timestamps[i]["id"] = i
    
    var stream = load(song_data["audio_file"])
    if stream:
        audio_player.stream = stream
```

### Step 2: Implement Core Comparison in _process()

```gdscript
# Add these variables to the class
var hit_windows = {
    "perfect": 0.040,   # ±40ms
    "great": 0.080,     # ±80ms
    "good": 0.120,      # ±120ms
    "ok": 0.180         # ±180ms
}

var score: int = 0
var combo: int = 0
var last_search_index: int = 0  # Optimization

func _process(_delta: float) -> void:
    if not audio_player.playing:
        return
    
    var current_time = audio_player.get_playback_position()
    
    # Process all queued inputs from this frame
    for input in queued_inputs:
        process_input(input, current_time)
    
    # Clean up processed inputs
    queued_inputs.clear()
    
    # Check for auto-missed notes
    check_missed_notes(current_time)

func process_input(input: Dictionary, current_time: float) -> void:
    # Find candidate notes within search window
    var candidates = find_nearby_notes(input["time"], 0.2)  # ±200ms window
    
    if candidates.is_empty():
        register_miss()
        return
    
    # Find the closest note
    var best_note = null
    var best_delta = INF
    
    for note in candidates:
        var delta = abs(input["time"] - note["time"])
        if delta < best_delta:
            best_delta = delta
            best_note = note
    
    # Validate hit against windows
    var hit_type = evaluate_hit(best_delta)
    
    if hit_type != "MISS":
        register_hit(best_note, hit_type)
        best_note["matched"] = true
    else:
        register_miss()

func find_nearby_notes(search_time: float, search_window: float) -> Array:
    var candidates = []
    
    # Start search near last found position (optimization)
    var search_start = max(0, last_search_index - 20)
    
    for i in range(search_start, timestamps.size()):
        var note = timestamps[i]
        
        # Skip already matched notes
        if note["matched"]:
            continue
        
        var delta = abs(note["time"] - search_time)
        
        # Only include notes within search window
        if delta <= search_window:
            candidates.append(note)
        
        # Optimization: stop searching when notes get too far ahead
        if note["time"] > search_time + search_window:
            last_search_index = i
            break
    
    return candidates

func evaluate_hit(delta: float) -> String:
    var abs_delta = abs(delta)
    
    if abs_delta <= hit_windows["perfect"]:
        return "PERFECT"
    elif abs_delta <= hit_windows["great"]:
        return "GREAT"
    elif abs_delta <= hit_windows["good"]:
        return "GOOD"
    elif abs_delta <= hit_windows["ok"]:
        return "OK"
    else:
        return "MISS"

func register_hit(note: Dictionary, hit_type: String) -> void:
    # Update score
    var points = {"PERFECT": 100, "GREAT": 80, "GOOD": 50, "OK": 10}
    score += points.get(hit_type, 0)
    
    # Update combo
    if hit_type in ["PERFECT", "GREAT"]:
        combo += 1
    else:
        combo = 0  # Break combo on GOOD or worse
    
    # Visual feedback (implement your own)
    show_hit_feedback(hit_type)

func register_miss() -> void:
    combo = 0
    # Visual feedback
    show_miss_feedback()

func check_missed_notes(current_time: float) -> void:
    for note in timestamps:
        if note["matched"]:
            continue
        
        # If we've passed the late window for this note
        if current_time - note["time"] > hit_windows["ok"]:
            note["matched"] = true
            register_miss()

func show_hit_feedback(hit_type: String) -> void:
    # TODO: Implement visual feedback
    # - Show hit indicator (Perfect/Great/Good/OK)
    # - Play sound effect
    # - Update UI
    print("HIT: %s" % hit_type)

func show_miss_feedback() -> void:
    # TODO: Implement miss feedback
    print("MISS")
```

---

## Phase 2: Optimization (After MVP Works)

Once you have the basic system working, optimize:

### Use Binary Search Instead of Linear

```gdscript
func find_nearby_notes_binary(search_time: float, search_window: float) -> Array:
    # Binary search to find insertion point
    var insertion_point = _binary_search_insertion_point(search_time)
    
    var candidates = []
    var window_min = search_time - search_window
    var window_max = search_time + search_window
    
    # Search backward
    var index = insertion_point - 1
    while index >= 0 and timestamps[index]["time"] >= window_min:
        if not timestamps[index]["matched"]:
            candidates.append(timestamps[index])
        index -= 1
    
    # Search forward
    index = insertion_point
    while index < timestamps.size() and timestamps[index]["time"] <= window_max:
        if not timestamps[index]["matched"]:
            candidates.append(timestamps[index])
        index += 1
    
    return candidates

func _binary_search_insertion_point(target_time: float) -> int:
    var left = 0
    var right = timestamps.size()
    
    while left < right:
        var mid = (left + right) / 2
        if timestamps[mid]["time"] < target_time:
            left = mid + 1
        else:
            right = mid
    
    return left
```

**When to switch:** When your songs have > 1,000 notes and you notice input processing taking > 0.5ms

### Add Latency Compensation

```gdscript
var latency_offset: float = 0.05  # 50ms default

func _on_input(type: String):
    var current_time = audio_player.get_playback_position()
    # Apply latency offset BEFORE storing
    var adjusted_time = current_time - latency_offset
    queued_inputs.push_back({"type": type, "time": adjusted_time})

# Calibration function (optional but recommended)
func calibrate_latency() -> void:
    # TODO: Implement calibration UI
    # User presses when they hear a beat, game measures offset
    pass
```

---

## Phase 3: Features (After Optimization)

### Add Difficulty Settings

```gdscript
var current_difficulty: int = 1  # 0=Easy, 1=Normal, 2=Hard, 3=Extreme

func get_hit_windows() -> Dictionary:
    var base_windows = {
        "perfect": 0.040,
        "great": 0.080,
        "good": 0.120,
        "ok": 0.180
    }
    
    # Adjust windows by difficulty
    var multiplier = 1.0
    match current_difficulty:
        0:  multiplier = 1.5   # Easy - larger windows
        1:  multiplier = 1.0   # Normal
        2:  multiplier = 0.75  # Hard - smaller windows
        3:  multiplier = 0.5   # Extreme - very tight
    
    for key in base_windows:
        base_windows[key] *= multiplier
    
    return base_windows
```

### Handle Multiple Simultaneous Inputs

```gdscript
func process_input(input: Dictionary, current_time: float) -> void:
    var candidates = find_nearby_notes(input["time"], 0.2)
    
    if candidates.is_empty():
        register_miss()
        return
    
    # Find best unmatched note
    var best_note = null
    var best_delta = INF
    
    for note in candidates:
        if note["matched"]:  # NEW: Skip already matched
            continue
        
        var delta = abs(input["time"] - note["time"])
        if delta < best_delta:
            best_delta = delta
            best_note = note
    
    if best_note == null:
        register_miss()
        return
    
    var hit_type = evaluate_hit(best_delta)
    if hit_type != "MISS":
        register_hit(best_note, hit_type)
        best_note["matched"] = true  # NEW: Mark immediately
    else:
        register_miss()
```

---

## Testing Checklist

- [ ] Load a song and verify notes are parsed correctly
- [ ] Hit a note and verify `PERFECT` is detected (±40ms)
- [ ] Hit a note late and verify `GREAT` is detected (±80ms)
- [ ] Miss a note completely and verify it auto-fails
- [ ] Test with rapid inputs to ensure simultaneous handling works
- [ ] Verify combo increases on hits and resets on misses
- [ ] Check score calculation is correct
- [ ] Profile performance - ensure input processing < 1ms

---

## Common Issues & Fixes

### Issue: Notes feel "off" or delayed

**Solution:** Adjust `latency_offset`
```gdscript
var latency_offset: float = 0.05  # Try 0.03, 0.05, 0.07, etc.
```

### Issue: Missing notes even when you hit them

**Solution:** Increase search window
```gdscript
var candidates = find_nearby_notes(input["time"], 0.3)  # ±300ms instead of 200ms
```

### Issue: Multiple inputs breaking the match

**Solution:** Mark notes as matched immediately
```gdscript
best_note["matched"] = true  # Do this BEFORE checking next input
```

### Issue: High CPU usage

**Solution:** Switch to binary search or spatial bucketing
```gdscript
# Instead of find_nearby_notes(), use:
var candidates = find_nearby_notes_binary(input["time"], 0.2)
```

---

## JSON Song Format Recommendations

Based on your current structure, here's the recommended format:

```json
{
  "title": "Song Name",
  "artist": "Artist Name",
  "bpm": 120,
  "audio_file": "res://songs/song.ogg",
  "offset": 0.0,
  "timestamps": [
    {
      "time": 0.5,
      "lane": 0,
      "type": "normal"
    },
    {
      "time": 1.0,
      "lane": 1,
      "type": "normal"
    },
    {
      "time": 1.5,
      "lane": 2,
      "type": "normal"
    }
  ]
}
```

---

## Next Steps

1. **Immediate:** Implement Phase 1 (MVP) in `game.gd`
2. **Test:** Verify basic hit detection works
3. **Optimize:** Add binary search when needed
4. **Polish:** Add visual feedback and UI
5. **Extend:** Add difficulties, calibration, scoring tiers

---

## Resources for Further Learning

- **Real rhythm game analysis:** Study open-source games like StepMania or osu!
- **Latency research:** Look into Audio latency compensation in Godot
- **Performance profiling:** Use Godot's built-in profiler to identify bottlenecks
- **Game feel:** Listen to how professional rhythm games feel and try to replicate that responsiveness

