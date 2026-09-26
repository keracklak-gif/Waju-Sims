# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## FFXIV-style GCD/oGCD timing for the player's healer actions. Pure logic,
## advanced by tick() - HealerAbilityBar drives it and handles the visuals.
##
## Rules modelled:
## - GCD actions share one recast (2.5s, or the action's own "gcd_recast"),
##   started the moment the action is pressed, cast time included. The
##   recast and cast times both scale by gcd_scale (Skill/Spell Speed).
## - Nothing can be used mid-cast. A completed cast leaves a short caster tax
##   lock, after which oGCDs can be woven until the next GCD.
## - Every instant action (oGCD or instant GCD) applies an animation lock that
##   blocks all other actions.
## - Pressing an action that is only blocked by timing (cast, lock, or GCD)
##   within QUEUE_WINDOW of it clearing queues it; a newer press replaces it.
## - oGCDs have their own recast and optional charges; some need a status
##   granted by another action (e.g. Divine Caress needs Temperance's Divine Grace).
##
## Ability dictionary keys (see HealerAbilities):
##   id, name, icon, gcd (bool), cast_time, gcd_recast, recast, charges,
##   requires (status), consumes (bool - removes the required status),
##   uses (statuses removed if present),
##   grants ({status: duration} - -1 = until used, "=other" = other's time left),
##   boost ({"status", "grants"} - replaces grants if that status is active)

class_name HealerActionController

signal cast_started(ability: Dictionary)
signal cast_finished(ability: Dictionary)
signal ability_executed(ability: Dictionary)

const GCD := 2.5
const ANIMATION_LOCK := 0.6
const CASTER_TAX := 0.1
const QUEUE_WINDOW := 0.5
const HISTORY_SIZE := 64

var gcd_left := 0.0
var gcd_total := GCD
var gcd_scale := 1.0  # Job's configured GCD / 2.5, set by ActionBar.
var cast_left := 0.0
var casting_ability: Dictionary = {}
var lock_left := 0.0
var queued_ability: Dictionary = {}
var charges := {}  # id -> charges ready
var recast_left := {}  # id -> seconds until the next charge comes back
var statuses := {}  # status -> seconds left (INF = until consumed)
var status_sources := {}  # status -> id of the ability that granted it
var expired_at := {}  # status -> clock time it ran out (not when consumed)
var clock := 0.0
var abilities := {}  # id -> ability
var cast_started_at := 0.0
## Recent actions that went off: {"id", "gcd", "start" (press/cast start),
## "end" (effect time), "granted" (statuses), "had" (statuses up just before)}.
var history: Array[Dictionary] = []
var last_hit_at := -INF  # clock time of the last damaging hit


func register(ability: Dictionary) -> void:
	abilities[ability["id"]] = ability
	charges[ability["id"]] = max_charges(ability)
	recast_left[ability["id"]] = 0.0


## Tries to use an ability now, or queues it. Returns false if it was refused.
func request(ability: Dictionary) -> bool:
	if not is_available(ability):
		return false
	var wait := time_until_ready(ability)
	if wait <= 0.0:
		execute(ability)
		return true
	if wait <= QUEUE_WINDOW:
		queued_ability = ability
		return true
	return false


func tick(delta: float) -> void:
	clock += delta
	for status: String in statuses.keys():
		statuses[status] -= delta
		if statuses[status] <= 0.0:
			statuses.erase(status)
			expired_at[status] = clock
	for id: String in abilities:
		if charges[id] >= max_charges(abilities[id]):
			continue
		recast_left[id] -= delta
		if recast_left[id] <= 0.0:
			charges[id] += 1
			recast_left[id] = recast_left[id] + abilities[id]["recast"] \
				if charges[id] < max_charges(abilities[id]) else 0.0
	gcd_left = maxf(gcd_left - delta, 0.0)
	lock_left = maxf(lock_left - delta, 0.0)
	if not casting_ability.is_empty():
		cast_left -= delta
		if cast_left <= 0.0:
			var ability := casting_ability
			casting_ability = {}
			cast_left = 0.0
			lock_left = CASTER_TAX
			apply_effects(ability, cast_started_at)
			cast_finished.emit(ability)
	if not queued_ability.is_empty() and time_until_ready(queued_ability) <= 0.0:
		var ability := queued_ability
		queued_ability = {}
		if is_available(ability):
			execute(ability)


## Player moved before the slidecast window. The cast never went off, so the
## GCD (and any recast the action spent) is refunded.
func interrupt_cast() -> void:
	if casting_ability.is_empty():
		return
	var id: String = casting_ability["id"]
	if casting_ability.get("recast", 0.0) > 0.0:
		charges[id] += 1
		if charges[id] >= max_charges(casting_ability):
			recast_left[id] = 0.0
	casting_ability = {}
	cast_left = 0.0
	gcd_left = 0.0
	queued_ability = {}


func execute(ability: Dictionary) -> void:
	var id: String = ability["id"]
	if ability.get("recast", 0.0) > 0.0:
		if charges[id] >= max_charges(ability):
			recast_left[id] = ability["recast"]
		charges[id] -= 1
	if ability.get("gcd", false):
		gcd_total = ability.get("gcd_recast", GCD) * gcd_scale
		gcd_left = gcd_total
	if ability.get("cast_time", 0.0) > 0.0:
		casting_ability = ability
		cast_left = ability["cast_time"] * gcd_scale
		cast_started_at = clock
		cast_started.emit(ability)
	else:
		lock_left = ANIMATION_LOCK
		apply_effects(ability, clock)


func apply_effects(ability: Dictionary, started_at: float) -> void:
	var had := statuses.keys()
	var grants: Dictionary = ability.get("grants", {})
	var boost: Dictionary = ability.get("boost", {})
	if not boost.is_empty() and statuses.has(boost["status"]):
		grants = boost["grants"]
	var durations := {}
	for status: String in grants:
		var duration: Variant = grants[status]
		if duration is String:
			duration = statuses.get(duration.trim_prefix("="), 0.0)
		elif duration < 0.0:
			duration = INF
		if duration > 0.0:
			durations[status] = duration
	if ability.get("consumes", false):
		statuses.erase(ability["requires"])
	for status: String in ability.get("uses", []):
		statuses.erase(status)
	for status: String in durations:
		statuses[status] = durations[status]
		status_sources[status] = ability["id"]
		expired_at.erase(status)
	history.append({"id": ability["id"], "gcd": ability.get("gcd", false), "start": started_at,
		"end": clock, "granted": durations.keys(), "had": had})
	if history.size() > HISTORY_SIZE:
		history.pop_front()
	ability_executed.emit(ability)


## A damaging hit landed: shields absorb it and are used up.
func absorb_hit(shields: Array) -> void:
	for status: String in shields:
		statuses.erase(status)
	last_hit_at = clock


## What each outcome of the ability could grant: its grants and its boost's.
static func possible_grants(ability: Dictionary) -> Array:
	var grants: Array = ability.get("grants", {}).keys()
	grants.append_array(ability.get("boost", {}).get("grants", {}).keys())
	return grants


## Requirements and recast/charges only - ignores GCD, cast and lock timing.
func is_available(ability: Dictionary) -> bool:
	if ability.has("requires") and not statuses.has(ability["requires"]):
		return false
	return charges.get(ability["id"], 0) > 0


func time_until_ready(ability: Dictionary) -> float:
	var wait := maxf(cast_left, lock_left)
	if ability.get("gcd", false):
		wait = maxf(wait, gcd_left)
	return wait


func is_casting() -> bool:
	return not casting_ability.is_empty()


func max_charges(ability: Dictionary) -> int:
	return ability.get("charges", 1)
