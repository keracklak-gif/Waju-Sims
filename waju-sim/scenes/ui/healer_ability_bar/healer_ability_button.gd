# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## An ActionButton whose cooldown display is read from a shared
## HealerActionController instead of its own timer, so GCD actions all sweep
## together. Presses only emit action_pressed; HealerAbilityBar decides
## whether the action goes off. If the ability has a follow_up, the button
## turns into it while it's usable (e.g. Temperance -> Divine Caress while
## Divine Grace is up), then back to the base ability and its cooldown.

extends ActionButton

class_name HealerAbilityButton

const UNAVAILABLE_MODULATE := Color(0.35, 0.35, 0.35)
const HOVER_MODULATE := Color(1.3, 1.3, 1.3)

var ability: Dictionary  # What the button uses right now: base or follow-up.
var base_ability: Dictionary
var follow_up: Dictionary
var base_texture: Texture2D
var follow_up_texture: Texture2D
var controller: HealerActionController
var hovered := false


func _ready() -> void:
	cooldown_label.hide()
	cooldown_sweep.value = 0
	mouse_entered.connect(func(): hovered = true)
	mouse_exited.connect(func(): hovered = false)
	set_process(false)


func setup(new_ability: Dictionary, new_controller: HealerActionController) -> void:
	ability = new_ability
	base_ability = new_ability
	follow_up = new_ability.get("follow_up", {})
	base_texture = texture_normal
	if not follow_up.is_empty():
		follow_up_texture = load(HealerAbilities.icon_path(follow_up))
	controller = new_controller
	cooldown_sweep.texture_progress = texture_normal
	set_process(true)


## The ability a press uses right now, refreshing the face first so a press
## in the same frame an unlock lands already gets the follow-up.
func current_ability() -> Dictionary:
	update_face()
	return ability


func update_face() -> void:
	var show_follow_up := not follow_up.is_empty() and controller.is_available(follow_up)
	var next := follow_up if show_follow_up else base_ability
	if next["id"] == ability["id"]:
		return
	ability = next
	texture_normal = follow_up_texture if show_follow_up else base_texture
	cooldown_sweep.texture_progress = texture_normal


func _process(_delta: float) -> void:
	update_face()
	var recast: float = ability.get("recast", 0.0)
	var max_charges := controller.max_charges(ability)
	var charges: int = controller.charges[ability["id"]]
	var recast_left: float = controller.recast_left[ability["id"]]
	cooldown_label.visible = false
	if charges == 0:
		cooldown_sweep.value = recast_left / recast * 100.0
		cooldown_label.text = "%d" % ceili(recast_left)
		cooldown_label.visible = true
	elif ability.get("gcd", false) and controller.gcd_left > 0.0:
		cooldown_sweep.value = controller.gcd_left / controller.gcd_total * 100.0
	else:
		cooldown_sweep.value = 0
	if max_charges > 1 and charges > 0:
		cooldown_label.text = str(charges)
		cooldown_label.visible = true
	var requirement_met: bool = not ability.has("requires") \
		or controller.statuses.has(ability["requires"])
	if not requirement_met:
		self_modulate = UNAVAILABLE_MODULATE
	elif hovered and texture_hover == null:
		self_modulate = HOVER_MODULATE
	else:
		self_modulate = Color.WHITE


func _on_pressed() -> void:
	action_pressed.emit()


func _on_cooldown_timer_timeout() -> void:
	pass
