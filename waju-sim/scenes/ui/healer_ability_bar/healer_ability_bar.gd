# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Hotbar of the selected healer job's cooldowns (HealerAbilities), bound to
## the hab1..hab8 keybinds (Shift+1..8 by default). Owns the
## HealerActionController that also times the action bar's filler cast, so
## filler and heal GCDs share one GCD and oGCDs can only be woven between
## casts. Hidden until ActionBar shows it.

extends MovableCanvasLayer

class_name HealerAbilityBar

const BUTTON_SCENE := preload("res://scenes/ui/healer_ability_bar/healer_ability_button.tscn")
## Saved keybind names, one per slot. Rebindable in the Controls menu.
const SLOT_KEYBINDS := ["hab1", "hab2", "hab3", "hab4", "hab5", "hab6", "hab7", "hab8"]
## Modifier prefixes shortened so a combo fits on a button, e.g. "Shift+1" -> "S1".
const SHORT_MODIFIERS := {"Shift+": "S", "Ctrl+": "C", "Alt+": "A", "Meta+": "M"}

@onready var buttons_container: HBoxContainer = %HealerButtonsContainer
@onready var move_ui_bg: Panel = %MoveUIBG

var controller := HealerActionController.new()
var player: Player
var player_cast_bar: PlayerCastBar
var buff_bar: HealerBuffBar
var job_name := ""
var slot_buttons: Array[HealerAbilityButton] = []
var keybinds: Dictionary


func _ready() -> void:
	section_key = "healer_ability_bar"
	GameEvents.ui_ready.connect(on_ui_ready)
	controller.cast_started.connect(on_cast_started)
	keybinds = SavedVariables.get_keybinds()
	SavedVariables.keybind_changed.connect(on_keybind_changed)
	hide()
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	controller.tick(delta)
	buff_bar.refresh()


## Called by ActionBar once the party is ready and the player is a healer.
func setup(new_player: Player, cast_bar: PlayerCastBar, filler: Dictionary,
		filler_button: HealerAbilityButton, new_buff_bar: HealerBuffBar) -> void:
	player = new_player
	player_cast_bar = cast_bar
	buff_bar = new_buff_bar
	buff_bar.controller = controller
	job_name = filler["job_name"]
	player.player_movement_controller.cast_interrupted.connect(on_cast_interrupted)
	controller.register(filler)
	filler_button.setup(filler, controller)
	var abilities := HealerAbilities.for_job(job_name)
	for i in mini(abilities.size(), SLOT_KEYBINDS.size()):
		add_slot(abilities[i], i)
	set_physics_process(true)


## Hiding also cancels any cast in progress, since its button is going away.
func set_bar_visible(is_visible: bool) -> void:
	visible = is_visible and not slot_buttons.is_empty()
	if buff_bar:
		buff_bar.visible = visible
	if not is_visible:
		on_cast_interrupted()


func add_slot(ability: Dictionary, index: int) -> void:
	controller.register(ability)
	if ability.has("follow_up"):
		controller.register(ability["follow_up"])
	var button: HealerAbilityButton = BUTTON_SCENE.instantiate()
	button.texture_normal = load(HealerAbilities.icon_path(ability))
	button.texture_hover = null
	buttons_container.add_child(button)
	button.setup(ability, controller)
	button.set_keybind_label(short_key_text(keybinds[SLOT_KEYBINDS[index]]))
	button.action_pressed.connect(func(): use(button.current_ability()))
	slot_buttons.append(button)


## Returns true if the key event was one of this bar's slot keys.
func handle_key(keycode: int) -> bool:
	if not visible:
		return false
	for i in slot_buttons.size():
		if keycode == keybinds[SLOT_KEYBINDS[i]]:
			use(slot_buttons[i].current_ability())
			return true
	return false


func on_keybind_changed(new_keybinds: Dictionary) -> void:
	keybinds = new_keybinds
	for i in slot_buttons.size():
		slot_buttons[i].set_keybind_label(short_key_text(keybinds[SLOT_KEYBINDS[i]]))


static func short_key_text(keycode: int) -> String:
	var text := OS.get_keycode_string(keycode)
	for modifier: String in SHORT_MODIFIERS:
		text = text.replace(modifier, SHORT_MODIFIERS[modifier])
	return text


func use(ability: Dictionary) -> void:
	if not player or player.is_player_frozen() or Global.spectate_mode or Global.is_moving_ui:
		return
	controller.request(ability)


func on_cast_started(ability: Dictionary) -> void:
	player.start_cast(ability["cast_time"])
	player_cast_bar.clear_casts()
	player_cast_bar.cast(ability["name"], ability["cast_time"])


func on_cast_interrupted() -> void:
	controller.interrupt_cast()
	if player_cast_bar:
		player_cast_bar.clear_casts()


func _on_margin_container_gui_input(event: InputEvent) -> void:
	if not Global.is_moving_ui:
		return
	if event is InputEventMouseButton:
		on_container_mouse_button_event(event)


func on_move_ui_on():
	if slot_buttons.is_empty():
		return
	move_ui_bg.show()


func on_move_ui_off():
	move_ui_bg.hide()
