# Rhythm Game Comparison Algorithms: Complete Workflow Research

## Overview

This document provides a comprehensive overview of how rhythm games compare user inputs against target notes, covering the technical workflows and algorithms used in production games.

---

## 1. Comparison Loop Structure

Rhythm games use three main patterns for the comparison loop:

### 1.1 Per-Frame Loop (Most Common)
**Used by:** Dance Dance Revolution, Guitar Hero, Rock Band, Beat Saber

The game logic runs on every frame, checking for hits:

```pseudo
GAME_LOOP:
  current_time = get_audio_playback_time()
  
  FOR EACH frame:
    queued_inputs = collect_player_inputs()  // All inputs this frame
    
    FOR EACH input IN queued_inputs:
      FOR EACH unmatched_note IN active_notes:
        delta = calculate_timing_delta(input.time, note.time)
        
        IF is_within_hit_window(delta):
          register_hit(input, note)
          mark_note_as_matched()
          remove_note_from_active_list()
          break  // Move to next input
    
    // Clean up missed notes
    FOR EACH note IN active_notes:
      IF note.time < current_time - MISS_THRESHOLD:
        register_miss(note)
        remove_note_from_active_list()
```

**Advantages:**
- Smooth, responsive feeling
- Easy to implement visual feedback
- Can handle overlapping inputs naturally
- Works well with 60+ fps games

**Disadvantages:**
- More CPU cycles per second
- Requires careful Delta time handling at high frame rates

### 1.2 Event-Based Loop
**Used by:** Some mobile games, specialized rhythm games

Triggered when input events occur:

```pseudo
ON_INPUT_EVENT(input_type, input_time):
  candidates = find_nearby_notes(input_time, SEARCH_WINDOW)
  
  IF candidates.length == 0:
    register_miss()
    return
  
  best_match = find_best_matching_note(candidates)
  
  IF is_within_hit_window(best_match):
    register_hit(best_match)
  ELSE:
    register_miss()
```

**Advantages:**
- Lower CPU usage (only processes on input)
- Simpler logic for single-input games
- Better for turn-based rhythm games

**Disadvantages:**
- Less responsive for dense note patterns
- Harder to handle simultaneous inputs
- Requires extra logic for "too early" inputs

### 1.3 Hybrid Approach
**Used by:** Osu!, Taiko no Tatsujin, modern mobile games

Combines per-frame checking with event-based triggering:

```pseudo
GAME_LOOP:
  current_time = get_audio_playback_time()
  
  // Per-frame cleanup and miss detection
  FOR EACH note IN active_notes:
    IF note.time + LATE_WINDOW < current_time:
      register_miss(note)
      remove_note()
  
ON_INPUT_EVENT(input_type, input_time):
  // Event-based matching
  candidates = find_nearby_notes(input_time, SEARCH_WINDOW)
  best = find_best_match(candidates)
  register_hit_or_miss(best)
```

**Advantages:**
- Responsive input handling
- Efficient CPU usage
- Good accuracy
- Scales well to high note densities

---

## 2. Note Search & Filtering Strategies

### 2.1 Sequential Scan (Simple Lists)
**Complexity:** O(n) per input

```pseudo
FUNCTION find_matching_note(input_time, search_window):
  best_match = null
  best_delta = INFINITY
  
  FOR i = 0 TO timestamps.length - 1:
    note = timestamps[i]
    
    IF note.matched:
      continue  // Skip already hit notes
    
    delta = ABS(note.time - input_time)
    
    IF delta > search_window:
      continue  // Outside search range
    
    IF delta < best_delta:
      best_delta = delta
      best_match = note
  
  RETURN best_match
```

**Best for:** Small songs (< 1000 notes), prototypes

**Optimization:** Sort by time first, then break early when delta increases
```pseudo
// Optimized version with early termination
FOR i = last_checked_index TO timestamps.length - 1:
  note = timestamps[i]
  delta = note.time - input_time
  
  IF delta > search_window:
    break  // All remaining notes are too late
  
  IF delta >= -search_window:  // Within window
    update_best_match(note)
```

### 2.2 Binary Search
**Complexity:** O(log n) per input

Used when notes are time-sorted:

```pseudo
FUNCTION binary_search_notes(input_time, search_window):
  // Find insertion point
  center = binary_search(timestamps, input_time)
  
  best_match = null
  best_delta = search_window
  
  // Search backward (earlier notes)
  index = center - 1
  WHILE index >= 0 AND timestamps[index].time > input_time - search_window:
    note = timestamps[index]
    delta = input_time - note.time
    
    IF delta < best_delta:
      best_delta = delta
      best_match = note
    
    index--
  
  // Search forward (later notes)
  index = center
  WHILE index < timestamps.length AND timestamps[index].time < input_time + search_window:
    note = timestamps[index]
    delta = ABS(note.time - input_time)
    
    IF delta < best_delta:
      best_delta = delta
      best_match = note
    
    index++
  
  RETURN best_match
```

**Best for:** Long songs (1000+ notes), real-time games

**Performance:** ~10-12 comparisons for 10,000 notes vs ~5,000 for linear scan

### 2.3 Spatial Indexing (Time Buckets)
**Complexity:** O(1) average case

Pre-divide timeline into buckets:

```pseudo
CLASS NoteTimeline:
  bucket_size = 0.1  // seconds, configurable
  buckets = new Map<int, List<Note>>()
  
  FUNCTION add_note(note):
    bucket_id = FLOOR(note.time / bucket_size)
    IF NOT buckets.contains(bucket_id):
      buckets[bucket_id] = new List()
    buckets[bucket_id].add(note)
  
  FUNCTION get_candidate_notes(input_time, search_window):
    candidates = new List()
    
    center_bucket = FLOOR(input_time / bucket_size)
    bucket_range = CEIL(search_window / bucket_size)
    
    FOR bucket_id = center_bucket - bucket_range TO center_bucket + bucket_range:
      IF buckets.contains(bucket_id):
        candidates.extend(buckets[bucket_id])
    
    RETURN candidates
```

**Best for:** Very long songs or streaming scenarios

**Example:** For a 5-minute song with 0.1s buckets:
- 3,000 buckets total
- Per input: check ~2-4 buckets = 5-20 candidate notes
- Linear scan on 5-20 notes is negligible

### 2.4 Hybrid: Sorted List + Early Termination
**Complexity:** O(k) where k is search window size

Often used in modern games:

```pseudo
CLASS OptimizedNoteList:
  notes = []  // Time-sorted
  last_hit_index = 0
  
  FUNCTION find_notes_near(input_time, search_window):
    // Start search near last hit
    search_start = max(0, last_hit_index - 10)
    candidates = []
    
    FOR i = search_start TO notes.length - 1:
      note = notes[i]
      
      IF note.matched:
        continue
      
      delta = ABS(note.time - input_time)
      
      IF delta <= search_window:
        candidates.add(note)
      ELSE IF note.time > input_time + search_window:
        break  // All remaining notes too late
    
    last_hit_index = search_start + i
    RETURN candidates
```

---

## 3. Timing Delta Calculation Methods

### 3.1 Simple Offset Calculation
**Most common approach:**

```pseudo
FUNCTION calculate_timing_delta(input_time, note_time):
  // Positive = hit too late, Negative = hit too early
  delta = input_time - note_time
  RETURN delta
```

### 3.2 Absolute Offset (Hit Window Agnostic)
Used for determining "how far off" independent of hit quality:

```pseudo
FUNCTION calculate_timing_delta_absolute(input_time, note_time):
  delta = input_time - note_time
  RETURN ABS(delta)
```

### 3.3 Audio Latency Compensation
Most games account for system latency:

```pseudo
FUNCTION calculate_timing_delta_with_latency_offset(input_time, note_time):
  // Calibration offset determined during game startup
  audio_latency = GlobalSettings.audio_latency_ms / 1000.0
  
  delta = (input_time - audio_latency) - note_time
  RETURN delta
```

**Common latency values:**
- Audio playback: 10-50ms (device dependent)
- Input detection: 5-20ms
- Display lag: 16-100ms (1 frame @ 60fps = 16.67ms)
- Total: 30-170ms typically

### 3.4 Normalized Delta (For UI/Feedback)
Convert to standardized units:

```pseudo
FUNCTION calculate_normalized_delta(input_time, note_time):
  raw_delta = input_time - note_time
  
  // Normalize to units of hit_window_size
  window_size = 0.05  // seconds (50ms)
  normalized = raw_delta / window_size
  
  // Clamped to [-1, 1] range
  RETURN clamp(normalized, -1.0, 1.0)
```

---

## 4. Hit Window Application & Validation

### 4.1 Standard Hit Windows

Typical configuration (in milliseconds):

```
PERFECT:  ±40ms (strict)
GREAT:    ±80ms
GOOD:     ±120ms
OK:       ±180ms
MISS:     >180ms

Total hit window: 360ms around each note
```

### 4.2 Window Validation Algorithm

```pseudo
FUNCTION validate_hit(note, input_time):
  delta = calculate_timing_delta(input_time, note.time)
  
  // Check from best to worst
  IF ABS(delta) <= PERFECT_WINDOW:
    RETURN HitType.PERFECT
  
  ELSE IF ABS(delta) <= GREAT_WINDOW:
    RETURN HitType.GREAT
  
  ELSE IF ABS(delta) <= GOOD_WINDOW:
    RETURN HitType.GOOD
  
  ELSE IF ABS(delta) <= OK_WINDOW:
    RETURN HitType.OK
  
  ELSE IF ABS(delta) <= MISS_WINDOW:
    RETURN HitType.MISS
  
  ELSE:
    RETURN HitType.TOO_EARLY  // Input before miss window
```

### 4.3 Per-Lane Window Adjustment
Some games tighten windows for easier play or looser for harder:

```pseudo
FUNCTION get_adjusted_window(base_window, difficulty):
  SWITCH difficulty:
    CASE EASY:
      return base_window * 1.5
    CASE NORMAL:
      return base_window
    CASE HARD:
      return base_window * 0.75
    CASE EXTREME:
      return base_window * 0.5
```

### 4.4 Calibration-Adjusted Windows
Modern rhythm games allow players to calibrate:

```pseudo
CLASS HitWindowCalibrator:
  base_perfect_window = 0.04
  calibration_offset = 0.0  // User can adjust ±0.05
  
  FUNCTION get_perfect_window():
    return base_perfect_window + calibration_offset
```

---

## 5. Edge Cases & Special Handling

### 5.1 Multiple Inputs at Same Time
**Problem:** Player presses multiple buttons simultaneously

```pseudo
FUNCTION handle_simultaneous_inputs(inputs_same_frame):
  // Sort by closest delta
  sorted_inputs = sort_by_delta(inputs_same_frame)
  matched_notes = []
  
  FOR EACH input IN sorted_inputs:
    // Find best unmatched note within window
    best_note = find_best_note(input)
    
    IF best_note NOT IN matched_notes:
      register_hit(input, best_note)
      matched_notes.add(best_note)
```

Example scenario:
- Notes at: 1.0s, 1.05s
- Input: two presses at exactly 1.03s
- Result: First press → 1.0s note (delta 30ms), Second press → 1.05s note (delta 20ms)

### 5.2 Duplicate Inputs (Double-Tap Prevention)
Some games require debounce to prevent accidental double hits:

```pseudo
CLASS InputDebouncer:
  min_input_gap = 0.01  // 10ms minimum between inputs
  last_input_time = -INFINITY
  
  FUNCTION is_valid_input(current_time):
    IF current_time - last_input_time < min_input_gap:
      RETURN false
    
    last_input_time = current_time
    RETURN true
```

### 5.3 Missed Notes Detection

```pseudo
FUNCTION check_for_missed_notes(current_time):
  FOR EACH unmatched_note IN active_notes:
    time_since_ideal = current_time - note.time
    
    // If past the late window, mark as missed
    IF time_since_ideal > LATE_WINDOW:
      register_miss(note)
      remove_note()
```

### 5.4 Early Input Handling
**Problem:** Player hits before the hit window opens

Strategy depends on game design:

**Option A: Ignore (Osu!, StepMania)**
```pseudo
IF input_time < note.time - EARLY_WINDOW:
  // Do nothing, input is ignored
  RETURN
```

**Option B: Store and Match Later (Guitar Hero)**
```pseudo
IF input_time < note.time - EARLY_WINDOW:
  pending_inputs.add({type, time})
  // Will be checked when note enters window
  RETURN

// Later, when note enters window:
FOR EACH pending_input IN pending_inputs:
  IF is_within_window(pending_input, note):
    register_hit(pending_input, note)
```

**Option C: Register as Miss (Strict Games)**
```pseudo
IF input_time < note.time - EARLY_WINDOW:
  register_miss()
  RETURN
```

### 5.5 Overlapping Notes (Chords)
**Problem:** Multiple notes at identical time

```pseudo
FUNCTION handle_chord(notes_at_same_time, inputs):
  // Match inputs to chord members by lane/channel
  matched_count = 0
  
  FOR EACH note IN notes_at_same_time:
    matching_input = find_input_for_lane(note.lane, inputs)
    
    IF matching_input:
      register_hit(matching_input, note)
      matched_count++
    ELSE:
      register_miss(note)
  
  RETURN matched_count
```

---

## 6. Common Optimization Strategies

### 6.1 Note Pooling
Avoid allocating/deallocating note objects:

```pseudo
CLASS NotePool:
  available_notes = []
  in_use_notes = []
  
  FUNCTION get_note():
    IF available_notes.length > 0:
      note = available_notes.pop()
    ELSE:
      note = new Note()
    
    in_use_notes.add(note)
    RETURN note
  
  FUNCTION return_note(note):
    in_use_notes.remove(note)
    note.reset()
    available_notes.add(note)
```

### 6.2 Only Update Visible Notes
Process only notes near playhead:

```pseudo
FUNCTION update_notes(current_time):
  visible_range = 3.0  // seconds ahead/behind
  
  FOR EACH note IN all_notes:
    IF ABS(note.time - current_time) <= visible_range:
      update_note_position(note)
    ELSE:
      skip_note(note)
```

### 6.3 Cache Last Search Position
Remember where we searched last:

```pseudo
CLASS CachedNoteSearch:
  last_search_time = 0.0
  last_search_index = 0
  
  FUNCTION find_notes_near(current_time):
    // Start search near last position
    search_start = max(0, last_search_index - SEARCH_BUFFER)
    
    // ... do search ...
    
    last_search_time = current_time
    last_search_index = found_index
```

### 6.4 Pre-calculate Note Trajectories
For scrolling notes:

```pseudo
FOR EACH note IN song.notes:
  note.screen_position = calculate_position(note.time, current_time)
  // Cache this rather than recalculating each frame
```

### 6.5 Adaptive Precision Based on Difficulty
Use different window sizes to optimize:

```pseudo
FUNCTION should_use_high_precision(difficulty):
  SWITCH difficulty:
    CASE EASY:
      return false  // Larger windows, less CPU intensive
    CASE HARD, EXTREME:
      return true   // Smaller windows, need precision
```

---

## 7. Practical Pseudocode Examples

### 7.1 Complete Per-Frame Rhythm Game Loop

```pseudo
CLASS RhythmGame:
  notes = []
  matched_notes = set()
  pending_inputs = []
  score = 0
  combo = 0
  
  FUNCTION initialize_song(song_data):
    notes = song_data.timestamps
    notes.sort_by_time()
    matched_notes.clear()
    pending_inputs.clear()
  
  FUNCTION _process(delta):
    current_time = audio_player.get_time()
    
    // Process queued inputs
    for_each input IN queued_inputs:
      process_input(input, current_time)
    
    // Check for missed notes
    check_missed_notes(current_time)
    
    // Update UI
    update_note_positions(current_time)
    
    queued_inputs.clear()
  
  FUNCTION process_input(input, input_time):
    // Early input handling
    IF input_time < oldest_note.time - SEARCH_WINDOW:
      pending_inputs.add(input)
      return
    
    // Find candidate notes
    candidates = find_nearby_notes(input_time, SEARCH_WINDOW)
    
    IF candidates.length == 0:
      register_miss()
      return
    
    // Find best match
    best_note = null
    best_delta = INFINITY
    
    FOR EACH note IN candidates:
      IF note IN matched_notes:
        continue
      
      delta = ABS(input_time - note.time)
      
      IF delta < best_delta:
        best_delta = delta
        best_note = note
    
    // Validate hit
    IF best_note == null:
      register_miss()
      return
    
    hit_type = validate_hit(best_note, input_time)
    
    IF hit_type != MISS:
      register_hit(best_note, hit_type, best_delta)
      matched_notes.add(best_note)
      combo++
    ELSE:
      register_miss()
      combo = 0
  
  FUNCTION check_missed_notes(current_time):
    FOR EACH note IN notes:
      IF note IN matched_notes:
        continue
      
      IF note.time + LATE_WINDOW < current_time:
        register_miss(note)
        matched_notes.add(note)
        combo = 0
  
  FUNCTION register_hit(note, hit_type, delta):
    score_gained = calculate_score(hit_type)
    score += score_gained
    
    // Visual feedback
    show_hit_feedback(hit_type, delta)
```

### 7.2 Timing Window Evaluation

```pseudo
FUNCTION evaluate_timing(delta, difficulty):
  // delta = input_time - note_time (in seconds)
  
  windows = get_windows_for_difficulty(difficulty)
  
  IF ABS(delta) <= windows.perfect:
    RETURN {type: PERFECT, score: 100, combo: true}
  
  ELSE IF ABS(delta) <= windows.great:
    RETURN {type: GREAT, score: 80, combo: true}
  
  ELSE IF ABS(delta) <= windows.good:
    RETURN {type: GOOD, score: 50, combo: false}
  
  ELSE IF ABS(delta) <= windows.ok:
    RETURN {type: OK, score: 10, combo: false}
  
  ELSE:
    RETURN {type: MISS, score: 0, combo: false}
```

### 7.3 Handling Dense Note Patterns

```pseudo
FUNCTION match_chord(inputs_this_frame, current_time):
  // Group inputs by lane
  inputs_by_lane = group_by_lane(inputs_this_frame)
  
  // Find notes at current time ±window
  candidate_notes = find_notes_near(current_time)
  notes_by_lane = group_by_lane(candidate_notes)
  
  hits = []
  
  FOR EACH lane IN inputs_by_lane:
    input = inputs_by_lane[lane]
    notes = notes_by_lane[lane]
    
    IF notes.length == 0:
      register_miss()
    ELSE:
      best_note = find_best_match(notes, input.time)
      hit_type = validate_hit(best_note, input.time)
      hits.add({note: best_note, type: hit_type})
  
  RETURN hits
```

---

## 8. Real-World Game Examples

### 8.1 Guitar Hero / Rock Band Pattern

```
Input Detection: Per-frame + event-based
Note Search: Sorted list + early termination
Timing Windows: 
  - Perfect: ±40ms
  - Great: ±80ms
  - Good: ±120ms
  - OK: ±160ms
Combo: Resets on Good or worse
Latency Compensation: 50-100ms calibration offset
```

### 8.2 Dance Dance Revolution Pattern

```
Input Detection: Per-frame
Note Search: Binary search on time-sorted array
Timing Windows:
  - Perfect: ±22ms
  - Great: ±61ms
  - Good: ±106ms
  - OK: ±156ms
Combo: Resets on any miss
Late Inputs: Rejected if > 156ms late
Multiple Inputs: First correct input wins
```

### 8.3 Osu! Pattern

```
Input Detection: Per-frame + event-based
Note Search: Spatial bucketing (0.05s buckets)
Timing Windows:
  - Perfect (300): ±40ms
  - Good (100): ±80ms
  - OK (50): ±120ms
Combo: Resets on miss only
Early Inputs: Completely ignored (no penalty)
Holds: Separate logic for hold notes
```

### 8.4 Beat Saber Pattern

```
Input Detection: Per-frame
Note Search: BVH (Bounding Volume Hierarchy) spatial structure
Timing Windows:
  - Perfect: ±0.05s + swing direction
  - Good: ±0.1s + swing direction
  - Miss: >0.15s or wrong direction
Combo: Any miss breaks combo
Multiple Notes: Priority based on distance/angle
Swing Direction: Validated separately from timing
```

---

## 9. Common Pitfalls & Solutions

| Problem | Cause | Solution |
|---------|-------|----------|
| Input feels unresponsive | Event-only matching | Add per-frame pre-checking |
| Missed hits at high BPM | O(n) search too slow | Switch to binary search or buckets |
| Latency issues | No compensation | Add calibration offset |
| Double-hits on single press | No debounce | Add 10ms minimum input gap |
| Notes feel "off" | Wrong delta calculation | Include audio latency in offset |
| High CPU on dense notes | Checking all notes each frame | Use spatial indexing |
| Combo breaking randomly | Missed note detection too loose | Tighten late window threshold |
| Unfair early hits | No early input handling | Explicitly ignore or store pending |

---

## 10. Recommended Implementation Stack

### For Beginners (Your Current Project)
1. **Loop Type:** Per-frame
2. **Search:** Sorted list + index caching
3. **Windows:** Standard (±40/80/120/180ms)
4. **Latency:** Fixed offset (50ms default, calibratable)

```pseudo
// Minimal implementation
FOR EACH input:
  candidates = find_notes(input.time, ±0.2s)
  best = closest_unmatched_note(candidates)
  
  IF best.matched == false:
    delta = input.time - best.time
    IF ABS(delta) < HIT_WINDOW:
      register_hit()
```

### For Production Games
1. **Loop Type:** Hybrid (per-frame + event)
2. **Search:** Binary search + early termination
3. **Windows:** Difficulty-adjusted + calibration
4. **Latency:** Audio + input + visual compensation
5. **Special:** Pending input queue, debounce, chord handling

### For High-Performance Games
1. **Loop Type:** Per-frame with delta tracking
2. **Search:** Spatial bucketing + pooling
3. **Windows:** Dynamic based on note density
4. **Latency:** Real-time audio API integration
5. **Special:** BVH spatial trees, SIMD optimizations

---

## Conclusion

The core rhythm game comparison algorithm is relatively simple, but production-quality games add layers of optimization and edge case handling:

1. **Responsiveness** comes from event-based input processing
2. **Accuracy** comes from proper timing window calibration
3. **Performance** comes from smart note searching
4. **Feel** comes from latency compensation and feedback

For your "Hit the Beat" project, starting with a simple per-frame sorted-list approach is ideal, then iterate based on user feedback on responsiveness and accuracy.

