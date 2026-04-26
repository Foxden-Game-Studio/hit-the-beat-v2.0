class Drum:
	const rack_tom_1 = "Rack Tom 1"
	const rack_tom_2 = "Rack Tom 2"
	const floor_tom_1 = "Floor Tom 1"
	const floor_tom_2 = "Floor Tom 2"
	const snare = "Snare Drum"
	const ride = "Ride"
	const crash_cymbal_1 = "Crash Cymbal 1"
	const crash_cymbal_2 = "Crash Cymbal 2"
	const hi_hat_1 = "Hi-Hat_1"
	const hi_hat_2 = "Hi-Hat_2"
	const bass = "Bass Drum"
	const undefined = ""

const PERFECT = "PERFECT"
const GREAT = "GREAT"
const GOOD = "GOOD"
const OK = "OK"
const MISS = "MISS"

const HIT_WINDOWS = {
	"PERFECT": 0.040,   # ±40ms
	"GREAT": 0.080,     # ±80ms
	"GOOD": 0.120,      # ±120ms
	"OK": 0.180         # ±180ms
}

const POINTS = {
	"PERFECT": 100,
	"GREAT": 80,
	"GOOD": 50,
	"OK": 10,
	"MISS": 0
}
const FEEDBACK_COLOR = {
	"PERFECT": Color.LIGHT_BLUE,
	"GREAT": Color.GREEN,
	"GOOD": Color.GREEN_YELLOW,
	"OK": Color.YELLOW,
	"MISS": Color.RED
}
