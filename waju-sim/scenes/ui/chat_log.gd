# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer
class_name ChatLog

const PARTY_CHAT_COLOR := Color(0.55, 0.85, 1.0)

@onready var move_ui_bg: Panel = %MoveUIBG
@onready var messages: RichTextLabel = $MarginContainer/Panel/VBoxContainer/Messages


func _ready():
	section_key = "chat_log"
	GameEvents.ui_ready.connect(on_ui_ready)


# Appends a line as if a party member ("Bob Robotson") typed it via macro.
func add_message(text: String) -> void:
	messages.append_text("[color=#%s][Party] Bob Robotson: %s[/color]\n" % [PARTY_CHAT_COLOR.to_html(false), text])
	messages.scroll_to_line(messages.get_line_count())


func clear_messages() -> void:
	messages.clear()


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
