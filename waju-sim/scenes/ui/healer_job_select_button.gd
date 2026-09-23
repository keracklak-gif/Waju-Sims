# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Selects which job a healer role plays (White Mage/Astrologian for h1,
## Scholar/Sage for h2), driving the cast bar's spell name shown by the
## action bar's cast button. Only shown when the player's selected role
## matches role_key, next to the role selector.

extends OptionButton

@export var role_key := "h2"


func _ready() -> void:
	var setting_key: String = Global.HEALER_JOB_SETTING_KEYS[role_key]
	selected = SavedVariables.save_data["settings"][setting_key]
	update_visibility()
	GameEvents.variable_saved.connect(on_variable_saved)


func _on_item_selected(index: int) -> void:
	GameEvents.emit_variable_saved("settings", Global.HEALER_JOB_SETTING_KEYS[role_key], index)


func on_variable_saved(section: String, key: String, _value: Variant) -> void:
	if section == "settings" and key == "player_role":
		update_visibility()


func update_visibility() -> void:
	var role_index: int = SavedVariables.save_data["settings"]["player_role"]
	visible = Global.ROLE_KEYS[role_index] == role_key
