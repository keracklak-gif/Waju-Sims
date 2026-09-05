# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer
class_name ChatLog

const PARTY_CHAT_COLOR := Color(0.55, 0.85, 1.0)
## FFXIV's own Echo channel color - a pale lavender, distinct from the blue
## used for party chat above so the two log windows read as different
## channels even when docked near each other.
const ECHO_CHAT_COLOR := Color(0.85, 0.75, 0.95)
const BOBOT_NAME := "Bob Robotson"
const PLAYER_NAME := "You"

## Per-instance so one scene can serve both the party chat log and the Echo
## log: the key this window saves its position/scale under (must have entries
## in MovableCanvasLayer's DEFAULT_UI_POSITIONS/SCALES) and the caption shown
## over it while the UI is unlocked.
@export var log_section_key := "chat_log"
@export var log_title := "Chat Log"
## When set, this log only ever has one channel - hide the FFXIV-style
## General/Battle/Event/Party tab strip and show just this label instead.
## Used by the Echo log, which never has a "Party" tab to speak of.
@export var single_tab_label := ""

@onready var move_ui_bg: Panel = %MoveUIBG
@onready var move_ui_label: Label = %MoveUILabel
@onready var messages: RichTextLabel = $MarginContainer/Panel/VBoxContainer/Messages
@onready var tabs: HBoxContainer = %Tabs


func _ready():
	section_key = log_section_key
	move_ui_label.set_text(log_title)
	if not single_tab_label.is_empty():
		for tab: Label in tabs.get_children():
			tab.hide()
		var solo_tab: Label = tabs.get_child(0)
		solo_tab.show()
		solo_tab.text = single_tab_label
		solo_tab.remove_theme_color_override("font_color")
	GameEvents.ui_ready.connect(on_ui_ready)


# Appends a line as if a party member ("Bob Robotson") typed it via macro.
func add_message(text: String) -> void:
	add_party_message(BOBOT_NAME, text)


# Appends a line as if the player typed it via a chat macro.
func add_player_message(text: String) -> void:
	add_party_message(PLAYER_NAME, text)


func add_party_message(sender: String, text: String) -> void:
	messages.append_text("[color=#%s][Party] %s: %s[/color]\n" % [PARTY_CHAT_COLOR.to_html(false), sender, text])
	messages.scroll_to_line(messages.get_line_count())


# Appends a line as sent through FFXIV's /echo channel - visible only to the
# player, so no sender name is shown (matches how the game itself renders it).
func add_echo_message(text: String) -> void:
	messages.append_text("[color=#%s][Echo] %s[/color]\n" % [ECHO_CHAT_COLOR.to_html(false), text])
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
