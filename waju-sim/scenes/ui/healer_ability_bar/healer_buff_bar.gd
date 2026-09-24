# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## The player's active healer buffs and their time left, read from the
## HealerActionController. Each buff uses the icon of the ability that granted
## it. HealerAbilityBar calls refresh() every tick and toggles visibility.

extends MovableCanvasLayer

class_name HealerBuffBar

const ICON_SIZE := Vector2(30, 30)

@onready var buffs_container: HBoxContainer = %HealerBuffsContainer
@onready var move_ui_bg: Panel = %MoveUIBG

var controller: HealerActionController
var entries := {}  # status -> {"box", "label"}
var label_settings := LabelSettings.new()


func _ready() -> void:
	section_key = "healer_buff_bar"
	GameEvents.ui_ready.connect(on_ui_ready)
	label_settings.font_size = 13
	label_settings.outline_size = 3
	label_settings.outline_color = Color.BLACK
	hide()


func refresh() -> void:
	for status: String in entries.keys():
		if not controller.statuses.has(status):
			entries[status]["box"].queue_free()
			entries.erase(status)
	for status: String in controller.statuses:
		if not entries.has(status):
			add_entry(status)
		var time_left: float = controller.statuses[status]
		entries[status]["label"].text = "" if is_inf(time_left) else str(ceili(time_left))


func add_entry(status: String) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	var icon := TextureRect.new()
	icon.custom_minimum_size = ICON_SIZE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var source: String = controller.status_sources[status]
	icon.texture = load(HealerAbilities.icon_path(controller.abilities.get(source, {"id": source})))
	icon.tooltip_text = HealerAbilities.status_name(status)
	var label := Label.new()
	label.label_settings = label_settings
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(icon)
	box.add_child(label)
	buffs_container.add_child(box)
	entries[status] = {"box": box, "label": label}


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	if visible:
		move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
