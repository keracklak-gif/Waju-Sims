# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer

@onready var sprint_action_button: ActionButton = $MarginContainer/ButtonsContainer/SprintActionButton
@onready var arms_action_button: ActionButton = $MarginContainer/ButtonsContainer/ArmsActionButton
@onready var dash_action_button: ActionButton = $MarginContainer/ButtonsContainer/DashActionButton
@onready var cast_action_button: ActionButton = $MarginContainer/ButtonsContainer/CastActionButton
@onready var player_cast_bar: PlayerCastBar = $PlayerCastBar
@onready var parent_node = $".."
@onready var control_menu: CanvasLayer = %ControlMenu
@onready var move_ui_bg: Panel = %MoveUIBG


var player: Player
var keybinds: Dictionary


func _ready() -> void:
	# Temp fix for heiarchy restructure
	if parent_node is not Sequence:
		parent_node = $"../.."
		assert(parent_node is Sequence)
	
	section_key = "action_bar"
	GameEvents.ui_ready.connect(on_ui_ready)
	
	GameEvents.party_ready.connect(on_party_ready)
	sprint_action_button.action_pressed.connect(on_sprint_pressed)
	arms_action_button.action_pressed.connect(on_arms_pressed)
	dash_action_button.action_pressed.connect(on_dash_pressed)
	cast_action_button.action_pressed.connect(on_cast_pressed)
	cast_action_button.hide()
	SavedVariables.keybind_changed.connect(on_keybind_changed)
	keybinds = SavedVariables.get_keybinds()
	update_keybinds()


# Handles Action Bar and Reset keybinds.
func _unhandled_input(event : InputEvent) -> void:
	if control_menu.visible or Global.is_moving_ui:
		return
	if event is InputEventKey:
		var keycode : int = event.get_keycode_with_modifiers()
		if keycode == keybinds["ab1_sprint"]:
			sprint_action_button._on_pressed()
		elif keycode == keybinds["ab2_arms"]:
			arms_action_button._on_pressed()
		elif keycode == keybinds["ab3_dash"]:
			dash_action_button._on_pressed()
		elif keycode == keybinds["ab5_cast"] and cast_action_button.visible:
			cast_action_button._on_pressed()
		elif keycode == keybinds["reset"]:
			if Input.is_action_just_pressed("reset"):  # Needed to stop ghost input from hanging after reset.
				parent_node._on_reset_button_pressed()
	# Controller button binds (non-configurable)
	elif event is InputEventJoypadButton:
		var button_index: int = event.get_button_index()
		match button_index:
			JOY_BUTTON_X:
				sprint_action_button._on_pressed()
			JOY_BUTTON_A:
				arms_action_button._on_pressed()
			JOY_BUTTON_B:
				dash_action_button._on_pressed()
			JOY_BUTTON_Y:  # BUG: InputEvent hangs on this input after reset.
				parent_node._on_reset_button_pressed()


func on_party_ready() -> void:
	player = get_tree().get_first_node_in_group("player")
	cast_action_button.visible = Global.HEALER_JOBS.has(Global.player_role_key)
	if cast_action_button.visible:
		var job: Dictionary = get_current_healer_job()
		var icon: Texture2D = load(job["icon"])
		cast_action_button.texture_normal = icon
		cast_action_button.texture_hover = load(job["icon_hl"])
		cast_action_button.cooldown_sweep.texture_progress = icon
		player.player_movement_controller.cast_interrupted.connect(on_cast_interrupted)


func get_current_healer_job() -> Dictionary:
	var setting_key: String = Global.HEALER_JOB_SETTING_KEYS[Global.player_role_key]
	return Global.HEALER_JOBS[Global.player_role_key][SavedVariables.save_data["settings"][setting_key]]


func on_keybind_changed(new_keybinds: Dictionary) -> void:
	keybinds = new_keybinds
	update_keybinds()


func update_keybinds() -> void:
	sprint_action_button.set_keybind_label(OS.get_keycode_string(keybinds["ab1_sprint"]))
	arms_action_button.set_keybind_label(OS.get_keycode_string(keybinds["ab2_arms"]))
	dash_action_button.set_keybind_label(OS.get_keycode_string(keybinds["ab3_dash"]))
	cast_action_button.set_keybind_label(OS.get_keycode_string(keybinds["ab5_cast"]))


func on_sprint_pressed() -> void:
	if !player:
		player = get_tree().get_first_node_in_group("player")
		if !player:
			print("Tried to sprint, but Player node could not be found.")
			return
	player.sprint()


func on_arms_pressed() -> void:
	if !player:
		player = get_tree().get_first_node_in_group("player")
		if !player:
			print("Tried to use ability, but Player node could not be found.")
			return
	player.arms_length()


func on_dash_pressed() -> void:
	if !player:
		player = get_tree().get_first_node_in_group("player")
		if !player:
			print("Tried to dash, but Player node could not be found.")
			return
	player.dash()


func on_cast_pressed() -> void:
	if !player:
		player = get_tree().get_first_node_in_group("player")
		if !player:
			print("Tried to cast, but Player node could not be found.")
			return
	var job: Dictionary = get_current_healer_job()
	player.start_cast(job["cast_time"])
	player_cast_bar.cast(job["spell_name"], job["cast_time"])


# Player moved before the slidecast window - the cast never went off, so
# there's no GCD to recover from. Clear the bar and free the button right away.
func on_cast_interrupted() -> void:
	player_cast_bar.clear_casts()
	cast_action_button.cooldown_timer.stop()
	cast_action_button._on_cooldown_timer_timeout()


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
