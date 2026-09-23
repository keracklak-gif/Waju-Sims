# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## The player's own debuffs on the boss (healer DoTs) and their time left.
## Tracking only: casting a debuff again just resets it to full duration.
## ActionBar calls apply() and toggles visibility for healers.

extends MovableCanvasLayer

class_name TargetDebuffBar

const ICON_SIZE := Vector2(30, 30)
const TICK := 0.1

@onready var debuffs_container: HBoxContainer = %TargetDebuffsContainer
@onready var move_ui_bg: Panel = %MoveUIBG

var entries := {}  # debuff name -> {"box", "label", "time_left"}
var label_settings := LabelSettings.new()


func _ready() -> void:
	section_key = "target_debuff_bar"
	GameEvents.ui_ready.connect(on_ui_ready)
	label_settings.font_size = 13
	label_settings.outline_size = 3
	label_settings.outline_color = Color.BLACK
	hide()
	# MovableCanvasLayer only runs _process while moving UI, so count down on a timer.
	var tick_timer := Timer.new()
	tick_timer.wait_time = TICK
	tick_timer.autostart = true
	tick_timer.timeout.connect(tick.bind(TICK))
	add_child(tick_timer)


func tick(delta: float) -> void:
	for debuff_name: String in entries.keys():
		var entry: Dictionary = entries[debuff_name]
		entry["time_left"] -= delta
		if entry["time_left"] <= 0.0:
			entry["box"].queue_free()
			entries.erase(debuff_name)
		else:
			entry["label"].text = str(ceili(entry["time_left"]))


func apply(debuff_name: String, icon: Texture2D, duration: float) -> void:
	if not entries.has(debuff_name):
		add_entry(debuff_name, icon)
	entries[debuff_name]["time_left"] = duration
	entries[debuff_name]["label"].text = str(ceili(duration))


func add_entry(debuff_name: String, icon_texture: Texture2D) -> void:
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 0)
	var icon := TextureRect.new()
	icon.custom_minimum_size = ICON_SIZE
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	icon.texture = icon_texture
	icon.tooltip_text = debuff_name
	var label := Label.new()
	label.label_settings = label_settings
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	box.add_child(icon)
	box.add_child(label)
	debuffs_container.add_child(box)
	entries[debuff_name] = {"box": box, "label": label, "time_left": 0.0}


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
