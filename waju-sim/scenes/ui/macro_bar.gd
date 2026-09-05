# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## FFXIV-style macro bar. Buttons are built at runtime from a per-encounter
## macro definition array (see DmuGlobal.P4_MACROS) so the bar can be reused
## by other encounters without a new scene.
##
## A macro can post to chat (macro_used), place a target marker on the player
## (marker_used), or both - which one fires is decided by the definition, not
## by the bar. Several bars can coexist in one scene as long as each instance
## is given its own bar_section_key.

extends MovableCanvasLayer
class_name MacroBar

signal macro_used(text: String)
signal marker_used(marker_key: String)

const MACRO_BUTTON_SCENE = preload("res://scenes/ui/macro_button.tscn")

## Per-instance so one scene can serve several bars: the key this bar saves its
## position and scale under, and the caption shown over it while the UI is
## unlocked. A section key must have entries in MovableCanvasLayer's
## DEFAULT_UI_POSITIONS/DEFAULT_UI_SCALES or resetting position will fail.
@export var bar_section_key := "macro_bar"
@export var bar_title := "Macro Bar"

@onready var buttons_container: GridContainer = %ButtonsContainer
@onready var move_ui_bg: Panel = %MoveUIBG
@onready var move_ui_label: Label = %MoveUILabel


func _ready() -> void:
	section_key = bar_section_key
	move_ui_label.set_text(bar_title)
	GameEvents.ui_ready.connect(on_ui_ready)


func set_macros(macro_defs: Array, columns: int = 4) -> void:
	buttons_container.columns = columns
	for child in buttons_container.get_children():
		buttons_container.remove_child(child)
		child.queue_free()
	for macro_def: Dictionary in macro_defs:
		var macro_button: MacroButton = MACRO_BUTTON_SCENE.instantiate()
		buttons_container.add_child(macro_button)
		macro_button.setup(macro_def)
		macro_button.macro_pressed.connect(on_macro_pressed)
		macro_button.marker_pressed.connect(on_marker_pressed)


func on_macro_pressed(text: String) -> void:
	macro_used.emit(text)


func on_marker_pressed(marker_key: String) -> void:
	marker_used.emit(marker_key)


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
