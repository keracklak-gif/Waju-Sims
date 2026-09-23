# Copyright 2025
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

extends MovableCanvasLayer

@onready var sprint_action_button: ActionButton = $MarginContainer/ButtonsContainer/SprintActionButton
@onready var arms_action_button: ActionButton = $MarginContainer/ButtonsContainer/ArmsActionButton
@onready var dash_action_button: ActionButton = $MarginContainer/ButtonsContainer/DashActionButton
@onready var cast_action_button: ActionButton = $MarginContainer/ButtonsContainer/CastActionButton
@onready var dot_action_button: ActionButton = $MarginContainer/ButtonsContainer/DotActionButton
@onready var player_cast_bar: PlayerCastBar = $PlayerCastBar
@onready var target_debuff_bar: TargetDebuffBar = $TargetDebuffBar
@onready var parent_node = $".."
@onready var control_menu: CanvasLayer = %ControlMenu
@onready var move_ui_bg: Panel = %MoveUIBG


var player: Player
var keybinds: Dictionary
var eukrasia_active := false  # Sage: Eukrasia used, next DoT press is Eukrasian Dosis.


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
	dot_action_button.action_pressed.connect(on_dot_pressed)
	dot_action_button.hide()
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
			cast_action_button._on_pressed()
		elif keycode == keybinds["ab6_dot"] and dot_action_button.visible:
			dot_action_button._on_pressed()
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
		update_cast_gcd()
		player.player_movement_controller.cast_interrupted.connect(on_cast_interrupted)
		dot_action_button.show()
		target_debuff_bar.show()
		update_dot_button()


func on_variable_saved(section: String, key: String, _value: Variant) -> void:
	if section == "settings" and cast_action_button.visible \
		and key == Global.get_cast_gcd_setting_key(Global.player_role_key, get_current_healer_job_index()):
		update_cast_gcd()


# Keeps the button's own GCD lockout duration in sync with the current
# job's configured GCD. Doesn't touch a cooldown that's already counting down.
func update_cast_gcd() -> void:
	if not cast_action_button.visible:
		return
	cast_action_button.cooldown = Global.get_cast_gcd(Global.player_role_key, get_current_healer_job_index())
	if cast_action_button.cooldown_timer.is_stopped():
		cast_action_button.cooldown_timer.wait_time = cast_action_button.cooldown


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
	dot_action_button.set_keybind_label(OS.get_keycode_string(keybinds["ab6_dot"]))


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
	# Like in game, Eukrasia also turns Dosis itself into Eukrasian Dosis.
	if eukrasia_active:
		apply_dot()
		return
	var job: Dictionary = get_current_healer_job()
	var cast_time: float = Global.get_scaled_cast_time(
		job["cast_time"], Global.player_role_key, get_current_healer_job_index())
	player.start_cast(cast_time)
	player_cast_bar.cast(job["spell_name"], cast_time)
	start_gcd(cast_action_button.cooldown)


# Instant DoT on the boss. Sage has to use Eukrasia first, which has its own
# short GCD and turns this button into Eukrasian Dosis III.
func on_dot_pressed() -> void:
	var dot: Dictionary = get_current_healer_job()["dot"]
	if dot.has("eukrasia") and not eukrasia_active:
		eukrasia_active = true
		update_dot_button()
		start_gcd(dot["eukrasia"]["gcd"])
		return
	apply_dot()


func apply_dot() -> void:
	var dot: Dictionary = get_current_healer_job()["dot"]
	eukrasia_active = false
	update_dot_button()
	target_debuff_bar.apply(dot["spell_name"], load_icon(dot["icon"]), dot["duration"])
	start_gcd(cast_action_button.cooldown)


## Cast and DoT share one GCD: using either locks both for the same time.
func start_gcd(duration: float) -> void:
	cast_action_button.start_cooldown(duration)
	dot_action_button.start_cooldown(duration)


# Shows the DoT, or Eukrasia for Sage until it's been used.
func update_dot_button() -> void:
	var dot: Dictionary = get_current_healer_job()["dot"]
	var shown: Dictionary = dot["eukrasia"] if dot.has("eukrasia") and not eukrasia_active else dot
	var icon := load_icon(shown["icon"])
	dot_action_button.texture_normal = icon
	dot_action_button.texture_hover = load_icon(shown["icon_hl"])
	dot_action_button.cooldown_sweep.texture_progress = icon
	dot_action_button.tooltip_text = shown["spell_name"]


# DoT icons aren't in every asset pack yet - fall back to the filler spell's
# icon so the button still works without them.
func load_icon(path: String) -> Texture2D:
	if ResourceLoader.exists(path):
		return load(path)
	return load(get_current_healer_job()["icon"])


# Player moved before the slidecast window - the cast never went off, so
# there's no GCD to recover from. Clear the bar and free the buttons right away.
func on_cast_interrupted() -> void:
	player_cast_bar.clear_casts()
	cast_action_button.clear_cooldown()
	dot_action_button.clear_cooldown()


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
