# Rhythm Game Comparison Algorithms - Quick Reference Guide

## Executive Summary

Rhythm games compare player inputs against target notes using a multi-stage pipeline:

1. **Collect Input** → capture user action with precise timestamp
2. **Adjust for Latency** → subtract system latency offset
3. **Search for Candidates** → find nearby notes efficiently
4. **Calculate Timing Delta** → measure time difference
5. **Validate Against Windows** → check if hit is within acceptable range
6. **Register Result** → record hit/miss and update score/combo
7. **Clean Up** → remove old missed notes

---

## Quick Algorithm Reference

### Algorithm 1: Simple Sequential Search (For Small Songs)

```gdscript
# GDScript (Godot) Implementation
func find_best_matching_note(input_time: float, search_window: float) -> Dictionary:
	var best_match = null
	var best_delta = INF
	
	for i in range(timestamps.size()):
		var note = timestamps[i]
		
		# Skip already matched notes
		if note.matched:
			continue
		
		# Calculate timing delta (in seconds)
		var delta = abs(input_time - note.time)
		
		# Skip if outside search window
		if delta > search_window:
			continue
		
		# Track the closest note
		if delta < best_delta:
			best_delta = delta
			best_match = note
	
	return best_match if best_match else {}
```

**Use Case:** Songs with < 500 notes, prototypes, or games running on older hardware

**Complexity:** O(n) per input (bad for large songs)

---

### Algorithm 2: Binary Search (Most Common for Production)

```gdscript
# GDScript Implementation - Binary Search + Expansion
func find_notes_binary_search(input_time: float, search_window: float) -> Array:
	# Step 1: Binary search to find insertion point
	var insertion_point = binary_search_insertion_point(input_time)
	
	var candidates = []
	var window_min = input_time - search_window
	var window_max = input_time + search_window
	
	# Step 2: Expand backward from insertion point
	var index = insertion_point - 1
	while index >= 0 and timestamps[index].time >= window_min:
		if not timestamps[index].matched:
			candidates.push_back(timestamps[index])
		index -= 1
	
	# Step 3: Expand forward from insertion point
	index = insertion_point
	while index < timestamps.size() and timestamps[index].time <= window_max:
		if not timestamps[index].matched:
			candidates.push_back(timestamps[index])
		index += 1
	
	return candidates

func binary_search_insertion_point(target_time: float) -> int:
	var left = 0
	var right = timestamps.size()
	
	while left < right:
		var mid = (left + right) / 2
		if timestamps[mid].time < target_time:
			left = mid + 1
		else:
			right = mid
	
	return left
```

**Use Case:** Production games with 500-20,000 notes

**Complexity:** O(log n) to find position + O(k) to expand where k = candidates

**Performance:** For 10,000 notes: ~14 binary search steps vs ~5,000 linear comparisons

---

### Algorithm 3: Spatial Bucketing (High Performance)

```gdscript
# GDScript Implementation - Time-based buckets
class_name NoteTimelineBucketed

var bucket_size: float = 0.1  # 100ms buckets
var buckets: Dictionary = {}  # bucket_id -> [notes]

func add_note(note: Dictionary) -> void:
	var bucket_id = int(note.time / bucket_size)
	
	if not buckets.has(bucket_id):
		buckets[bucket_id] = []
	
	buckets[bucket_id].append(note)

func get_candidate_notes(input_time: float, search_window: float) -> Array:
	var center_bucket = int(input_time / bucket_size)
	var bucket_range = int(ceil(search_window / bucket_size))
	
	var candidates = []
	
	# Search only relevant buckets
	for bucket_offset in range(-bucket_range, bucket_range + 1):
		var bucket_id = center_bucket + bucket_offset
		
		if buckets.has(bucket_id):
			for note in buckets[bucket_id]:
				if not note.matched:
					candidates.append(note)
	
	return candidates
```

**Use Case:** Very long songs (20,000+ notes), streaming scenarios

**Complexity:** O(1) average case to access buckets + O(k) to iterate candidates

**Performance:** For 20,000 notes with 0.1s buckets: Direct access to ~2-4 buckets = ~10-20 candidate notes to check

---

## Core Comparison Function

```gdscript
# The main comparison function used by all algorithms
func process_input(input_type: String, input_time: float) -> void:
	# Step 1: Apply latency compensation
	var adjusted_time = input_time - latency_offset
	
	# Step 2: Find candidate notes (use algorithm of choice)
	var candidates = find_candidate_notes(adjusted_time, SEARCH_WINDOW)
	
	if candidates.is_empty():
		register_miss()
		return
	
	# Step 3: Find best matching note
	var best_note = find_best_note(candidates, adjusted_time)
	
	if best_note == null:
		register_miss()
		return
	
	# Step 4: Calculate timing delta
	var delta = adjusted_time - best_note.time
	
	# Step 5: Validate against hit windows
	var hit_result = evaluate_timing_window(delta, difficulty)
	
	if hit_result.valid:
		register_hit(best_note, hit_result)
		best_note.matched = true
	else:
		register_miss()

func find_best_note(candidates: Array, input_time: float) -> Dictionary:
	var best = null
	var best_delta = INF
	
	for note in candidates:
		var delta = abs(input_time - note.time)
		if delta < best_delta:
			best_delta = delta
			best = note
	
	return best

func evaluate_timing_window(delta: float, difficulty: int) -> Dictionary:
	var windows = get_windows_for_difficulty(difficulty)
	
	if abs(delta) <= windows.perfect:
		return {"valid": true, "type": "PERFECT", "score": 100}
	elif abs(delta) <= windows.great:
		return {"valid": true, "type": "GREAT", "score": 80}
	elif abs(delta) <= windows.good:
		return {"valid": true, "type": "GOOD", "score": 50}
	elif abs(delta) <= windows.ok:
		return {"valid": true, "type": "OK", "score": 10}
	else:
		return {"valid": false, "type": "MISS", "score": 0}

func get_windows_for_difficulty(difficulty: int) -> Dictionary:
	var windows = {
		"perfect": 0.040,  # ±40ms
		"great": 0.080,    # ±80ms
		"good": 0.120,     # ±120ms
		"ok": 0.180        # ±180ms
	}
	
	# Adjust for difficulty
	match difficulty:
		0:  # Easy
			for key in windows:
				windows[key] *= 1.5
		2:  # Hard
			for key in windows:
				windows[key] *= 0.75
		3:  # Extreme
			for key in windows:
				windows[key] *= 0.5
	
	return windows
```

---

## Timing Delta Calculation

```gdscript
# The core timing calculation - this is critical for feel
func calculate_timing_delta(input_time: float, note_time: float) -> float:
	# Simple form: positive = late, negative = early
	return input_time - note_time

# With latency compensation
func calculate_timing_delta_with_compensation(
	input_time: float,
	note_time: float,
	audio_latency: float
) -> float:
	# Remove latency offset that affected the audio playback
	adjusted_input = input_time - audio_latency
	return adjusted_input - note_time

# For visual feedback (normalized)
func calculate_timing_indicator(delta: float, window_size: float = 0.05) -> float:
	# Returns -1.0 to 1.0 representing how far off the hit was
	var normalized = delta / window_size
	return clamp(normalized, -1.0, 1.0)
```

---

## Missed Note Detection

```gdscript
# Run this every frame to mark notes as automatically missed
func check_missed_notes(current_time: float) -> void:
	for note in timestamps:
		if note.matched:
			continue
		
		# If note is past its late window, mark as missed
		var time_since_note = current_time - note.time
		
		if time_since_note > LATE_WINDOW:  # Typically 0.18s
			register_miss(note)
			note.matched = true
			combo = 0  # Break combo
```

---

## Handling Multiple Simultaneous Inputs

```gdscript
# Process multiple inputs that occur at the same frame
func process_multiple_inputs(inputs: Array, current_time: float) -> void:
	# Sort inputs by how close they are to their best-matching notes
	inputs.sort_custom(func(a, b):
		var delta_a = find_best_delta(a, current_time)
		var delta_b = find_best_delta(b, current_time)
		return delta_a < delta_b  # Process best matches first
	)
	
	for input in inputs:
		# Find candidates
		var candidates = find_candidate_notes(current_time, SEARCH_WINDOW)
		
		# Exclude already-matched notes
		candidates = candidates.filter(func(note): return not note.matched)
		
		if candidates.is_empty():
			register_miss()
			continue
		
		# Find and process best match
		var best_note = find_best_note(candidates, current_time)
		process_input_against_note(input, best_note, current_time)
```

---

## Latency Calibration

```gdscript
# Calibration mode: user presses when they HEAR the beat
func calibrate_latency() -> void:
	# Generate test beat
	emit_test_sound()
	
	# Wait for user input
	var input_time = await wait_for_input()
	
	# Get corresponding audio time
	var audio_marker_time = audio_player.get_playback_position()
	
	# Calculate offset
	latency_offset = input_time - audio_marker_time
	
	# Store for future use
	GlobalSettings.save_latency_offset(latency_offset)
	
	print("Calibrated latency: %.0fms" % (latency_offset * 1000))

# Example: If user presses at 2.500s but audio marker is at 2.450s:
# latency_offset = 0.050 (50ms)
# Future calculations will subtract this: adjusted = input_time - 0.050
```

---

## Edge Case Handlers

### Early Input Prevention

```gdscript
# Option 1: Ignore early inputs
func is_input_in_valid_range(input_time: float, note_time: float) -> bool:
	var time_before_note = note_time - input_time
	
	# Reject if more than 200ms before the note
	if time_before_note > 0.20:
		return false
	
	return true

# Option 2: Queue pending inputs (for "too early" presses)
var pending_inputs = []

func queue_early_input(input: Dictionary, input_time: float) -> void:
	pending_inputs.append({
		"type": input.type,
		"time": input_time,
		"queued_at": current_time
	})

func try_match_pending_inputs(note_time: float) -> bool:
	for pending in pending_inputs:
		var delta = note_time - pending.time
		if abs(delta) < HIT_WINDOW:
			# Retroactively match this pending input
			register_hit(note_time, delta)
			pending_inputs.erase(pending)
			return true
	return false
```

### Double-Tap Prevention (Debouncing)

```gdscript
class_name InputDebouncer

var last_input_time: float = -INF
var debounce_threshold: float = 0.01  # 10ms minimum between inputs

func is_valid_input(current_time: float) -> bool:
	if current_time - last_input_time < debounce_threshold:
		return false
	
	last_input_time = current_time
	return true
```

---

## Summary Table: Which Algorithm to Use?

| Song Size | Typical BPM/Density | Algorithm | Pros | Cons |
|-----------|-------------------|-----------|------|------|
| < 500 notes | Any | Linear Scan | Simple, good for prototypes | Slow on large songs |
| 500-10,000 notes | Standard | Binary Search | Good balance, fast enough | Slightly complex |
| 10,000+ notes | High density | Spatial Bucketing | Very fast, scales well | Need pre-processing |
| Streaming | Variable | Bucketing + sliding window | Constant memory | Complex implementation |
| Mobile | Standard | Binary Search or Bucketing | Fast, low memory | Device dependent |
| VR (Beat Saber) | High | Spatial + BVH trees | Handles complex scenarios | Very complex |

---

## Performance Tips

1. **Cache the last search position** - don't start from zero every time
2. **Use object pooling** for notes - avoid allocate/deallocate overhead
3. **Only update visible notes** - process only notes within ~3 seconds of playhead
4. **Pre-sort notes by time** - critical for binary search and spatial bucketing
5. **Consider difficulty-based precision** - easy mode doesn't need tight windows
6. **Profile your specific hardware** - test linear vs binary vs bucketing

---

## Real-Game Implementations

**Guitar Hero/Rock Band:**
- Search: Sorted list with early termination
- Windows: ±40ms (Perfect), ±80ms (Great), ±120ms (Good), ±160ms (OK)
- Combo: Resets on Good or worse

**Dance Dance Revolution:**
- Search: Binary search on sorted array
- Windows: ±22ms (Perfect), ±61ms (Great), ±106ms (Good), ±156ms (OK)
- Combo: Resets on any miss
- Extra: Rejects inputs after a certain late threshold

**Osu!:**
- Search: Spatial bucketing
- Windows: ±40ms (300pts), ±80ms (100pts), ±120ms (50pts)
- Early inputs: Completely ignored (no penalty)
- Combo: Only breaks on misses, not on early presses

**Beat Saber:**
- Search: Spatial (BVH trees for 3D positions)
- Windows: ±50ms + direction validation
- Extra: Swing direction must match (not just timing)

