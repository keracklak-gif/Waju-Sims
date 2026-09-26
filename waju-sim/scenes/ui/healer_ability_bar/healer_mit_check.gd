# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Checks one AoE hit of a phase's healer mitigation plan (P4HealerMit,
## P5HealerMit). A phase lists every AoE hit in timeline order as
## {"name", "time", "new", "carry"}: "time" = when it lands in the phase's
## timeline, "new" = buffs the job must have freshly up (the healer sheet's
## plain text), "carry" = buffs that must still be lasting from an earlier hit
## (the sheet's grey "->" text), each keyed by job name. Hits the sheet has no
## plan for leave both empty and only check the healing shield.
##
## Healing shield ("All mechanics requires shields!"): every hit uses up a
## shield healer's GCD shield, so they must reapply it between hits.
## - A hit at least MIN_SHIELD_GAP after the previous one leaves time to, so
##   the shield must be up. Any of the job's shields counts; a hit that plans a
##   specific one (Spreadlo, Zoe shields) needs that one instead.
## - Faster hits (Flood, Fell Forces autos, back-to-back Forsaken) don't, so
##   there the healer just has to keep reapplying it as much as possible: the
##   shield is up, or they've been working on it since the last hit (casting
##   it, or pressed Eukrasia for it). And never cast one over a shield that's
##   still up, which wastes the GCD.

class_name HealerMitCheck

## Seconds between hits needed to reapply a shield: a GCD (2.5s) plus room to
## react and weave.
const MIN_SHIELD_GAP := 4.0

## Shield healer -> their healing shield's name, the statuses that count as it,
## and "prep" statuses a GCD grants on the way to it (Sage's Eukrasia).
const HEALING_SHIELDS := {
	"Scholar": {"name": "Galvanize",
		"statuses": ["galvanize", "catalyze", "deployed_galvanize", "spreadlo"], "prep": []},
	"Sage": {"name": "Eukrasian Prognosis II",
		"statuses": ["eukrasian_prognosis", "zoe_shields"], "prep": ["eukrasia"]},
}


## Adds a fail for each planned buff the player's job is missing at this hit,
## then lets the hit use up the player's shields.
static func check(mechanics: Array, index: int, controller: HealerActionController,
		job_name: String, fail_list: FailList) -> void:
	var mechanic: Dictionary = mechanics[index]
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
	var gap: float = mechanic["time"] - mechanics[index - 1]["time"] if index > 0 else INF
	check_healing_shield(mechanic, gap, controller, job_name, fail_list)
	controller.absorb_hit(HealerAbilities.SHIELDS)


static func check_healing_shield(mechanic: Dictionary, gap: float,
		controller: HealerActionController, job_name: String, fail_list: FailList) -> void:
	if not HEALING_SHIELDS.has(job_name):
		return
	var shield: Dictionary = HEALING_SHIELDS[job_name]
	# The plan already asked for a specific shield, checked above.
	for status: String in mechanic["new"].get(job_name, []):
		if status in shield["statuses"]:
			return
	var is_up := has_any(controller.statuses.keys(), shield["statuses"])
	if gap >= MIN_SHIELD_GAP:
		if not is_up:
			fail_list.add_fail("Player didn't have their %s shield up for %s." % [
				shield["name"], mechanic["name"]])
		return
	if overwrote_since(controller, shield):
		fail_list.add_fail("Player overwrote their %s shield before %s." % [
			shield["name"], mechanic["name"]])
	if not is_up and not worked_on_since(controller, shield):
		fail_list.add_fail("Player didn't keep reapplying their %s shield for %s." % [
			shield["name"], mechanic["name"]])


## A GCD shield landed since the last hit while one was still up.
static func overwrote_since(controller: HealerActionController, shield: Dictionary) -> bool:
	for entry: Dictionary in controller.history:
		if entry["end"] >= controller.last_hit_at and entry["gcd"] \
				and has_any(entry["granted"], shield["statuses"]) \
				and has_any(entry["had"], shield["statuses"]):
			return true
	return false


## Since the last hit the player has cast (or is casting) their shield, or
## pressed the GCD that leads into it and is still holding it.
static func worked_on_since(controller: HealerActionController, shield: Dictionary) -> bool:
	if controller.is_casting() and has_any(
			HealerActionController.possible_grants(controller.casting_ability), shield["statuses"]):
		return true
	for entry: Dictionary in controller.history:
		if entry["end"] < controller.last_hit_at:
			continue
		if has_any(entry["granted"], shield["statuses"]):
			return true
		for status: String in shield["prep"]:
			if status in entry["granted"] and controller.statuses.has(status):
				return true
	return false


static func has_any(statuses: Array, wanted: Array) -> bool:
	for status: String in wanted:
		if status in statuses:
			return true
	return false
