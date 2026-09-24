# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Checks one raidwide of a phase's healer mitigation plan (P4HealerMit,
## P5HealerMit). A mechanic is {"name", "new", "carry"}: "new" = buffs the job
## must have freshly up (the healer sheet's plain text), "carry" = buffs that
## must still be lasting from an earlier hit (the sheet's grey "->" text), each
## keyed by job name.
##
## On top of the plan, a shield healer must have their healing shield up for
## every raidwide ("All mechanics requires shields!"). Any of the job's shields
## counts; a hit that plans a specific one (Spreadlo, Zoe shields) needs that
## one instead.

class_name HealerMitCheck

## Shield healer -> the shields that count as their healing shield, and its name.
const HEALING_SHIELDS := {
	"Scholar": {"name": "Galvanize",
		"statuses": ["galvanize", "catalyze", "deployed_galvanize", "spreadlo"]},
	"Sage": {"name": "Eukrasian Prognosis II",
		"statuses": ["eukrasian_prognosis", "zoe_shields"]},
}


## Adds a fail for each planned buff the player's job is missing at this hit,
## then lets the hit use up the player's shields.
static func check(mechanic: Dictionary, controller: HealerActionController, job_name: String,
		fail_list: FailList) -> void:
	for status: String in mechanic["new"].get(job_name, []):
		if not controller.statuses.has(status):
			fail_list.add_fail("Player didn't have %s up for %s." % [
				HealerAbilities.status_name(status), mechanic["name"]])
	for status: String in mechanic["carry"].get(job_name, []):
		if controller.statuses.has(status):
			continue
		if controller.expired_at.has(status):
			fail_list.add_fail("Player's %s wore off before %s." % [
				HealerAbilities.status_name(status), mechanic["name"]])
		else:
			fail_list.add_fail("Player didn't have %s up for %s." % [
				HealerAbilities.status_name(status), mechanic["name"]])
	check_healing_shield(mechanic, controller, job_name, fail_list)
	controller.absorb_hit(HealerAbilities.SHIELDS)


## Adds a fail if a shield healer has none of their healing shields up. Skipped
## when the plan already asks this hit for a specific shield, checked above.
static func check_healing_shield(mechanic: Dictionary, controller: HealerActionController,
		job_name: String, fail_list: FailList) -> void:
	if not HEALING_SHIELDS.has(job_name):
		return
	var shield: Dictionary = HEALING_SHIELDS[job_name]
	for status: String in mechanic["new"].get(job_name, []):
		if status in shield["statuses"]:
			return
	for status: String in shield["statuses"]:
		if controller.statuses.has(status):
			return
	fail_list.add_fail("Player didn't have their %s shield up for %s." % [
		shield["name"], mechanic["name"]])
