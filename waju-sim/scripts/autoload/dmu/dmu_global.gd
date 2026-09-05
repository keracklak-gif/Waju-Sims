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
# are deliberately left alone; Cancel 1/2 and Chain 1/2 are reserved for
# other use. Text must match the Bob Robotson callouts in p4_seq.gd.
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
