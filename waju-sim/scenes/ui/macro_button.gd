# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends TextureButton
class_name MacroButton

signal macro_pressed(text: String)
## Emitted by macros that place a target marker on the player rather than (or
## as well as) posting to chat. Carries a TargetMarkerController marker key.
signal marker_pressed(marker_key: String)

## Short gate so a mashed button cannot flood the chat log. Macros have no
## real cooldown, so this is deliberately invisible (no sweep, no label).
const SPAM_GATE := 0.5
## Stands in for a hand-made "_hl" hover texture: the game icon is used
## unmodified and simply brightened while hovered.
const HOVER_BRIGHTEN := 1.3

@export var macro_text := ""
@export var marker_key := ""
@export var badge := ""

@onready var badge_label: Label = %BadgeLabel
@onready var spam_timer: Timer = %SpamTimer


func _ready() -> void:
	spam_timer.wait_time = SPAM_GATE
	apply_config()


# Configures the button from a macro definition (see DmuGlobal.P4_MACROS).
func setup(macro_def: Dictionary) -> void:
	macro_text = macro_def.get("text", "")
	marker_key = macro_def.get("marker", "")
	badge = macro_def.get("badge", "")
	texture_normal = macro_def.get("icon", null)
	tooltip_text = macro_def.get("tooltip", macro_text)
	if is_node_ready():
		apply_config()


func apply_config() -> void:
	badge_label.set_text(badge)


func _on_pressed() -> void:
	# Spectating only freezes the player's own movement/fail-checks - the
	# player character (and its Lockon/TargetMarker node) still exists in the
	# party, so macros stay usable for practicing callouts and self-marks
	# without controlling a character.
	if Global.is_moving_ui:
		return
	if macro_text.is_empty() and marker_key.is_empty():
		return
	if not spam_timer.is_stopped():
		return
	spam_timer.start()
	if not macro_text.is_empty():
		macro_pressed.emit(macro_text)
	if not marker_key.is_empty():
		marker_pressed.emit(marker_key)


func _on_mouse_entered() -> void:
	self_modulate = Color(HOVER_BRIGHTEN, HOVER_BRIGHTEN, HOVER_BRIGHTEN)


func _on_mouse_exited() -> void:
	self_modulate = Color.WHITE
