# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer

@onready var sprint_action_button: ActionButton = $MarginContainer/ButtonsContainer/SprintActionButton
@onready var arms_action_button: ActionButton = $MarginContainer/ButtonsContainer/ArmsActionButton
@onready var dash_action_button: ActionButton = $MarginContainer/ButtonsContainer/DashActionButton
@onready var cast_action_button: HealerAbilityButton = $MarginContainer/ButtonsContainer/CastActionButton
@onready var player_cast_bar: PlayerCastBar = $PlayerCastBar
@onready var healer_ability_bar: HealerAbilityBar = $HealerAbilityBar
@onready var healer_buff_bar: HealerBuffBar = $HealerBuffBar
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
	GameEvents.variable_saved.connect(on_variable_saved)
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
			if event.is_pressed() and not event.is_echo():
				cast_action_button._on_pressed()
		elif event.is_pressed() and not event.is_echo() and healer_ability_bar.handle_key(keycode):
			pass
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
		cast_action_button.texture_normal = load(job["icon"])
		cast_action_button.texture_hover = load(job["icon_hl"])
		var filler := {"id": "filler", "name": job["spell_name"], "gcd": true,
			"cast_time": job["cast_time"], "job_name": job["job_name"]}
		healer_ability_bar.setup(player, player_cast_bar, filler, cast_action_button, healer_buff_bar)
		update_cast_gcd()


## Shows or hides healer casting practice: the filler cast button and the
## healer cooldown bar together. Phases that never call this keep the filler
## button on for healers and the cooldown bar off.
func set_healer_cooldowns_visible(is_visible: bool) -> void:
	var shown := is_visible and Global.HEALER_JOBS.has(Global.player_role_key)
	cast_action_button.visible = shown
	healer_ability_bar.set_bar_visible(shown)


func on_variable_saved(section: String, key: String, _value: Variant) -> void:
	if section == "settings" and Global.HEALER_JOBS.has(Global.player_role_key) \
		and key == Global.get_cast_gcd_setting_key(Global.player_role_key, get_current_healer_job_index()):
		update_cast_gcd()


# Scales every healer GCD (recast and cast time) to the current job's
# configured GCD, like Skill/Spell Speed. Doesn't touch a GCD already rolling.
func update_cast_gcd() -> void:
	if not Global.HEALER_JOBS.has(Global.player_role_key):
		return
	healer_ability_bar.controller.gcd_scale = Global.get_cast_gcd(
		Global.player_role_key, get_current_healer_job_index()) / Global.BASE_GCD


func get_current_healer_job_index() -> int:
	var setting_key: String = Global.HEALER_JOB_SETTING_KEYS[Global.player_role_key]
	return SavedVariables.save_data["settings"][setting_key]


func get_current_healer_job() -> Dictionary:
	return Global.HEALER_JOBS[Global.player_role_key][get_current_healer_job_index()]


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
	healer_ability_bar.use(cast_action_button.ability)


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
