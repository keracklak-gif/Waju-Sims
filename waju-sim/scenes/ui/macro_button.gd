# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends TextureButton
class_name MacroButton

signal macro_pressed(text: String)

## Short gate so a mashed button cannot flood the chat log. Macros have no
## real cooldown, so this is deliberately invisible (no sweep, no label).
const SPAM_GATE := 0.5
## Stands in for a hand-made "_hl" hover texture: the game icon is used
## unmodified and simply brightened while hovered.
const HOVER_BRIGHTEN := 1.3

@export var macro_text := ""
@export var badge := ""

@onready var badge_label: Label = %BadgeLabel
@onready var spam_timer: Timer = %SpamTimer


func _ready() -> void:
	spam_timer.wait_time = SPAM_GATE
	apply_config()


# Configures the button from a macro definition (see DmuGlobal.P4_MACROS).
func setup(macro_def: Dictionary) -> void:
	macro_text = macro_def.get("text", "")
	badge = macro_def.get("badge", "")
	texture_normal = macro_def.get("icon", null)
	tooltip_text = macro_def.get("tooltip", macro_text)
	if is_node_ready():
		apply_config()


func apply_config() -> void:
	badge_label.set_text(badge)


func _on_pressed() -> void:
	if Global.spectate_mode or Global.is_moving_ui or macro_text.is_empty():
		return
	if not spam_timer.is_stopped():
		return
	spam_timer.start()
	macro_pressed.emit(macro_text)


func _on_mouse_entered() -> void:
	self_modulate = Color(HOVER_BRIGHTEN, HOVER_BRIGHTEN, HOVER_BRIGHTEN)


func _on_mouse_exited() -> void:
	self_modulate = Color.WHITE
