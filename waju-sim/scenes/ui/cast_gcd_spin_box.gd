# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Edits the GCD (seconds) used to scale the healer practice cast's cast
## time and button lockout - stands in for Skill/Spell Speed, which the real
## game uses to shrink both. Each job has its own saved GCD, so this retargets
## to whichever healer job is currently selected (role + job dropdowns).

extends SpinBox


func _ready() -> void:
	refresh_value()
	GameEvents.variable_saved.connect(on_variable_saved)


func _on_value_changed(new_value: float) -> void:
	var role_key: String = Global.get_selected_role_key()
	if not Global.HEALER_JOB_SETTING_KEYS.has(role_key):
		return
	var job_index: int = Global.get_selected_healer_job_index(role_key)
	GameEvents.emit_variable_saved("settings", Global.get_cast_gcd_setting_key(role_key, job_index), new_value)


func on_variable_saved(section: String, key: String, _value: Variant) -> void:
	if section != "settings":
		return
	if key == "player_role" or key == "healer1_job" or key == "healer2_job":
		refresh_value()


func refresh_value() -> void:
	var role_key: String = Global.get_selected_role_key()
	if not Global.HEALER_JOB_SETTING_KEYS.has(role_key):
		editable = false
		return
	editable = true
	var job_index: int = Global.get_selected_healer_job_index(role_key)
	set_value_no_signal(Global.get_cast_gcd(role_key, job_index))
