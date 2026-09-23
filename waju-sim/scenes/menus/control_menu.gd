# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

# TODO: Made keybinds exclusive.

extends CanvasLayer

enum {SPRINT, ARMS, DASH, CAST, RESET, MOVE_UI}

const PRESS_KEY_TEXT = "Press Key"

@onready var move_ui_key_button: Button = %MoveUIKeyButton
@onready var sprint_key_button: Button = %SprintKeyButton
@onready var arms_key_button: Button = %ArmsKeyButton
@onready var dash_key_button: Button = %DashKeyButton
@onready var cast_key_button: Button = %CastKeyButton
@onready var reset_key_button: Button = %ResetKeyButton
@onready var buttons := [%SprintKeyButton, %ArmsKeyButton, %DashKeyButton, %CastKeyButton, %ResetKeyButton, %MoveUIKeyButton]
@onready var mouse_sens_h_slider: HSlider = %MouseSensHSlider
@onready var x_sens_h_slider: HSlider = %XSensHSlider
@onready var y_sens_h_slider: HSlider = %YSensHSlider
@onready var invert_y_check_button: CheckButton = %InvertYCheckButton
@onready var party_order_margin_container: PartyOrderMenu = %PartyOrderMarginContainer
@onready var control_margin_container: MarginContainer = %ControlMarginContainer
@onready var keybinds_menu_container: MarginContainer = %KeybindsMenuContainer

var awaited_key: Variant
var saved_var_keys := ["ab1_sprint", "ab2_arms", "ab3_dash", "ab5_cast", "reset", "move_ui"]
var awaiting_ui := false
var encounter_menu: CanvasLayer
var healer_keys_page: MarginContainer


func _ready() -> void:
	encounter_menu = get_node_or_null("EncounterMenu")
	awaited_key = null
	# Set keybind button text.
	move_ui_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["move_ui"]))
	sprint_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["ab1_sprint"]))
	arms_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["ab2_arms"]))
	dash_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["ab3_dash"]))
	cast_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["ab5_cast"]))
	reset_key_button.set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"]["reset"]))
	# Set sliders
	mouse_sens_h_slider.set_value_no_signal(SavedVariables.save_data["settings"]["mouse_sens"])
	x_sens_h_slider.set_value_no_signal(SavedVariables.save_data["settings"]["x_sens"])
	y_sens_h_slider.set_value_no_signal(SavedVariables.save_data["settings"]["y_sens"])
	invert_y_check_button.set_pressed_no_signal(SavedVariables.save_data["settings"]["invert_y"])
	build_healer_keys_page()
	visibility_changed.connect(close_healer_keys_page)


func _unhandled_input(event : InputEvent) -> void:
	# Only take in keyboard inputs.
	if event is not InputEventKey:
		return
	var keycode : int = event.get_keycode_with_modifiers()
	# Handle open/closing control menu.
	if keycode == KEY_ESCAPE and event.is_pressed():
		awaited_key = null
		if encounter_menu and encounter_menu.visible:
			encounter_menu.hide_menu()
		else:
			self.visible = !self.visible
		return
	# Handle keybind input.
	if awaited_key == null:
		return
	if (keycode == KEY_SHIFT or keycode == KEY_CTRL or keycode == KEY_ALT) and !awaiting_ui:
		return
	GameEvents.emit_variable_saved("keybinds", saved_var_keys[awaited_key], keycode)
	buttons[awaited_key].set_text(OS.get_keycode_string(keycode))
	awaited_key = null
	awaiting_ui = false


func _on_move_ui_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = MOVE_UI
	move_ui_key_button.set_text(PRESS_KEY_TEXT)
	awaiting_ui = true


func _on_sprint_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = SPRINT
	sprint_key_button.set_text(PRESS_KEY_TEXT)


func _on_arms_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = ARMS
	arms_key_button.set_text(PRESS_KEY_TEXT)


func _on_dash_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = DASH
	dash_key_button.set_text(PRESS_KEY_TEXT)


func _on_cast_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = CAST
	cast_key_button.set_text(PRESS_KEY_TEXT)


func _on_reset_key_button_pressed() -> void:
	if awaited_key != null:
		return
	awaited_key = RESET
	reset_key_button.set_text(PRESS_KEY_TEXT)


# Healer cooldown slot keybinds live on their own page, since the Controls page
# is full. Built from the Controls page's own header, Cast row and Back button
# so it matches their style. Each slot is appended to buttons/saved_var_keys,
# so the shared rebind handling in _unhandled_input() covers them.
func build_healer_keys_page() -> void:
	var controls_vbox: VBoxContainer = control_margin_container.get_node("LeftButtonsVBox")
	healer_keys_page = MarginContainer.new()
	healer_keys_page.custom_minimum_size = control_margin_container.custom_minimum_size
	for side in ["left", "top", "right", "bottom"]:
		healer_keys_page.add_theme_constant_override("margin_" + side,
			control_margin_container.get_theme_constant("margin_" + side))
	healer_keys_page.hide()
	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", controls_vbox.get_theme_constant("separation"))
	var header: Label = controls_vbox.get_node("HeaderLabel").duplicate(0)
	header.text = "Healer Cooldowns"
	vbox.add_child(header)
	for i in HealerAbilityBar.SLOT_KEYBINDS.size():
		var saved_key: String = HealerAbilityBar.SLOT_KEYBINDS[i]
		var row: HBoxContainer = controls_vbox.get_node("CastContainer").duplicate(0)
		var label: Label = row.get_child(0)
		label.text = "Cooldown Slot %d" % (i + 1)
		var button: Button = row.get_child(1)
		button.unique_name_in_owner = false
		button.text = OS.get_keycode_string(SavedVariables.save_data["keybinds"][saved_key])
		button.pressed.connect(_on_keybind_button_pressed.bind(buttons.size(), button))
		buttons.append(button)
		saved_var_keys.append(saved_key)
		vbox.add_child(row)
	var back_button: Button = controls_vbox.get_node("BottomHBoxContainer/BackButton").duplicate(0)
	back_button.text = "Back"
	back_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	back_button.size_flags_vertical = Control.SIZE_EXPAND | Control.SIZE_SHRINK_END
	back_button.pressed.connect(close_healer_keys_page)
	vbox.add_child(back_button)
	healer_keys_page.add_child(vbox)
	keybinds_menu_container.add_child(healer_keys_page)


func _on_keybind_button_pressed(index: int, button: Button) -> void:
	if awaited_key != null:
		return
	awaited_key = index
	button.set_text(PRESS_KEY_TEXT)


func _on_healer_keys_button_pressed() -> void:
	control_margin_container.hide()
	healer_keys_page.show()


# Also runs when the menu is closed, so it reopens on the Controls page.
func close_healer_keys_page() -> void:
	if not healer_keys_page.visible:
		return
	awaited_key = null
	# Undo a "Press Key" left on a slot whose rebind was abandoned.
	for index in saved_var_keys.size():
		if saved_var_keys[index] in HealerAbilityBar.SLOT_KEYBINDS:
			buttons[index].set_text(OS.get_keycode_string(SavedVariables.save_data["keybinds"][saved_var_keys[index]]))
	healer_keys_page.hide()
	control_margin_container.show()


func _on_mouse_sens_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		GameEvents.emit_variable_saved("settings", "mouse_sens", mouse_sens_h_slider.get_value())


func _on_x_sens_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		GameEvents.emit_variable_saved("settings", "x_sens", x_sens_h_slider.get_value())


func _on_y_sens_h_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		GameEvents.emit_variable_saved("settings", "y_sens", y_sens_h_slider.get_value())


func _on_invert_y_check_button_toggled(toggled_on: bool) -> void:
	GameEvents.emit_variable_saved("settings", "invert_y", toggled_on)


func _on_back_button_pressed() -> void:
	self.hide()


func _on_pt_list_button_pressed() -> void:
	control_margin_container.hide()
	party_order_margin_container.show()
