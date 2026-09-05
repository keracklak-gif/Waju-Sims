# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## FFXIV-style macro bar. Buttons are built at runtime from a per-encounter
## macro definition array (see DmuGlobal.P4_MACROS) so the bar can be reused
## by other encounters without a new scene.

extends MovableCanvasLayer
class_name MacroBar

signal macro_used(text: String)

const MACRO_BUTTON_SCENE = preload("res://scenes/ui/macro_button.tscn")

@onready var buttons_container: GridContainer = %ButtonsContainer
@onready var move_ui_bg: Panel = %MoveUIBG


func _ready() -> void:
	section_key = "macro_bar"
	GameEvents.ui_ready.connect(on_ui_ready)


func set_macros(macro_defs: Array) -> void:
	for child in buttons_container.get_children():
		buttons_container.remove_child(child)
		child.queue_free()
	for macro_def: Dictionary in macro_defs:
		var macro_button: MacroButton = MACRO_BUTTON_SCENE.instantiate()
		buttons_container.add_child(macro_button)
		macro_button.setup(macro_def)
		macro_button.macro_pressed.connect(on_macro_pressed)


func on_macro_pressed(text: String) -> void:
	macro_used.emit(text)


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
