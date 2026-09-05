# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends Node

## DMU settings
## P2 Light Rampant
#var p2_force_puddles := false


# P4 chat macros (Macro Bar). Icons come from FFXIV's own MACRO SYMBOL set
# (ui/icon/066000), the grey tiles the in-game macro icon picker offers.
# Gaze: check = real, X = fake, badged with which cast. Chaos: every
# button gets its own glyph - the element glyph for the donut and a
# spiral for the twister - badged with the element. The target markers
# are deliberately left alone; Cancel 1/2 and Chain 1/2 belong to the
# Labeling Macro Bar below. Text must match the Bob Robotson callouts in
# p4_seq.gd.
const P4_MACROS: Array[Dictionary] = [
	# Row 1
	{
		"text": "--- 1ST GAZE REAL (Look Away) ---",
		"tooltip": "1st Grand Cross gaze is real - look away.",
		"icon": preload("res://assets/common/icons/macro_icons/gaze_real_icon.png"),
		"badge": "1",
	},
	{
		"text": "--- 1ST GAZE FAKE (Look In) ---",
		"tooltip": "1st Grand Cross gaze is fake - look in.",
		"icon": preload("res://assets/common/icons/macro_icons/gaze_fake_icon.png"),
		"badge": "1",
	},
	{
		"text": "--- WATER IS DONUT ---",
		"tooltip": "Tsunami is the donut - go in.",
		"icon": preload("res://assets/common/icons/macro_icons/water_donut_icon.png"),
		"badge": "W",
	},
	{
		"text": "--- WATER IS TWISTER ---",
		"tooltip": "Tsunami is the twister - go out.",
		"icon": preload("res://assets/common/icons/macro_icons/water_twister_icon.png"),
		"badge": "W",
	},
	# Row 2
	{
		"text": "--- 2ND GAZE REAL (Look Away) ---",
		"tooltip": "2nd Grand Cross gaze is real - look away.",
		"icon": preload("res://assets/common/icons/macro_icons/gaze_real_icon.png"),
		"badge": "2",
	},
	{
		"text": "--- 2ND GAZE FAKE (Look In) ---",
		"tooltip": "2nd Grand Cross gaze is fake - look in.",
		"icon": preload("res://assets/common/icons/macro_icons/gaze_fake_icon.png"),
		"badge": "2",
	},
	{
		"text": "--- FIRE IS TWISTER ---",
		"tooltip": "Inferno is the twister - go out.",
		"icon": preload("res://assets/common/icons/macro_icons/fire_twister_icon.png"),
		"badge": "F",
	},
	{
		"text": "--- FIRE IS DONUT ---",
		"tooltip": "Inferno is the donut - go in.",
		"icon": preload("res://assets/common/icons/macro_icons/fire_donut_icon.png"),
		"badge": "F",
	},
]


# Self-marking macros (Labeling Macro Bar). Unlike P4_MACROS these place an
# FFXIV target marker on the player instead of posting to chat, so each entry
# carries a "marker" key that indexes TargetMarkerController.marker_scene_paths.
# Which pair the bar offers depends on the player's role - support marks itself
# with Cancel, DPS with Chain - so the two arrays are never shown together.
# Icons are the raw overhead-marker glyphs re-baked onto the same grey tile
# background as the other macro icons above (see cancel1_icon.png etc.) - the
# glyph alone reads as a floating overhead marker, not a button, once shrunk
# to macro-button size. They already carry the numeral, so no badge is set.
# Nothing here is phase-specific: other DMU phases can reuse these as-is.
# (The marker scenes these "marker" keys resolve to need their own export
# anchor - see the comment on TargetMarkerController.marker_scene_paths.)
#
# Both arrays end with the same two Echo-only reminder macros (Acceleration
# Bomb's real behavior is "stay still" despite the name; its fake tell is
# "keep moving") - these are plain "text" macros like P4_MACROS, but posted to
# EchoChatLog instead of the party ChatLog since they're a private self-note,
# not a party callout. Icons are FFXIV's own Play/Pause macro-icon-picker
# tiles (same grey tile family as the rest), matching the action each button
# reminds the player to take rather than the debuff's misleading name.
const LABEL_MACROS_SUP: Array[Dictionary] = [
	{
		"marker": "stop_1",
		"tooltip": "Mark yourself Cancel 1. Press again to clear.",
		"icon": preload("res://assets/common/icons/macro_icons/cancel1_icon.png"),
	},
	{
		"marker": "stop_2",
		"tooltip": "Mark yourself Cancel 2. Press again to clear.",
		"icon": preload("res://assets/common/icons/macro_icons/cancel2_icon.png"),
	},
	{
		"text": "--- ACCELERATION (Stay Still) ---",
		"tooltip": "Echo-only reminder: Acceleration Bomb - stay still.",
		"icon": preload("res://assets/common/icons/macro_icons/stay_still_icon.png"),
	},
	{
		"text": "--- STILLNESS (Keep Moving) ---",
		"tooltip": "Echo-only reminder: Stillness - keep moving.",
		"icon": preload("res://assets/common/icons/macro_icons/keep_moving_icon.png"),
	},
]

const LABEL_MACROS_DPS: Array[Dictionary] = [
	{
		"marker": "link_1",
		"tooltip": "Mark yourself Chain 1. Press again to clear.",
		"icon": preload("res://assets/common/icons/macro_icons/chain1_icon.png"),
	},
	{
		"marker": "link_2",
		"tooltip": "Mark yourself Chain 2. Press again to clear.",
		"icon": preload("res://assets/common/icons/macro_icons/chain2_icon.png"),
	},
	{
		"text": "--- ACCELERATION (Stay Still) ---",
		"tooltip": "Echo-only reminder: Acceleration Bomb - stay still.",
		"icon": preload("res://assets/common/icons/macro_icons/stay_still_icon.png"),
	},
	{
		"text": "--- STILLNESS (Keep Moving) ---",
		"tooltip": "Echo-only reminder: Stillness - keep moving.",
		"icon": preload("res://assets/common/icons/macro_icons/keep_moving_icon.png"),
	},
]


# DMU Preset Waymarks
var waymarks := {
	"preset_1": {
		"name": "Diamond",
		"wm_1": Vector2(-13.8, -13.8), "wm_2": Vector2(13.8, -13.8), "wm_3": Vector2(13.8, 13.8), "wm_4": Vector2(-13.8, 13.8),
		"wm_a": Vector2(0, -27.6), "wm_b": Vector2(27.6, 0), "wm_c": Vector2(0, 27.6), "wm_d": Vector2(-27.6, 0)
	},
	"preset_2": {
		"name": "Cross (X13)",
		"wm_1": Vector2(-14.955397, -14.955397), "wm_2": Vector2(14.955397, -14.955397),
		"wm_3": Vector2(14.955397, 14.955397), "wm_4": Vector2(-14.955397, 14.955397),
		"wm_a": Vector2(-28.24936, -28.24936), "wm_b": Vector2(28.24936, -28.24936),
		"wm_c": Vector2(28.24936, 28.24936),"wm_d": Vector2(-28.24936, 28.24936)
	},
	"preset_3": {
		"name": "Circle",
		"wm_1": Vector2(-21.15, -21.15), "wm_2": Vector2(21.15, -21.15), "wm_3": Vector2(21.15, 21.15), "wm_4": Vector2(-21.15, 21.15),
		"wm_a": Vector2(0, -29.375), "wm_b": Vector2(29.375, 0), "wm_c": Vector2(0, 29.375), "wm_d": Vector2(-29.375, 0)
	},
	"current": {}
}
