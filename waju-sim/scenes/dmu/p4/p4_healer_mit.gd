# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## P4 healer mitigation plan, from the DMU healer sheet's "P4 | Kefka Says"
## tab. For each raidwide: "new" = buffs the job must have freshly up (the
## sheet's plain text), "carry" = buffs that must still be lasting from an
## earlier hit (the sheet's grey "->" text). Checked by P4Seq.check_healer_mit()
## at the hit times in p4_anim (each cast's end), which sit ~17s behind the
## sheet's phase clock.
##
## Left out: the sheet's Scholar "-> Sacred Soil" into the 2nd Grand Cross.
## Soil lasts 15s and the two Grand Crosses are 14.9s apart, so it can't carry.

class_name P4HealerMit

const MECHANICS := [
	{"name": "Grand Cross", "sheet_time": "0:29", # p4_anim 12.4
		"new": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["spreadlo", "sacred_soil"], "Sage": ["kerachole", "philosophia", "holos"]},
		"carry": {}},
	{"name": "Inferno/Tsunami", "sheet_time": "0:35", # 17.4
		"new": {},
		"carry": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole", "holos"]}},
	{"name": "Grand Cross", "sheet_time": "0:44", # 27.3
		"new": {"White Mage": ["temperance"], "Astrologian": ["neutral_sect"],
			"Scholar": ["expedient", "fey_illumination"], "Sage": ["panhaima"]},
		"carry": {"Sage": ["holos"]}},
	{"name": "Inferno/Tsunami", "sheet_time": "0:49", # 32.4
		"new": {"Astrologian": ["sun_sign"], "Scholar": ["consolation"]},
		"carry": {"White Mage": ["temperance"], "Astrologian": ["neutral_sect"],
			"Scholar": ["expedient", "fey_illumination"], "Sage": ["panhaima"]}},
	{"name": "Grand Cross", "sheet_time": "0:59", # 42.4
		"new": {"White Mage": ["divine_caress"], "Scholar": ["consolation"], "Sage": ["zoe_shields"]},
		"carry": {"White Mage": ["temperance"], "Astrologian": ["neutral_sect", "sun_sign"],
			"Scholar": ["expedient", "fey_illumination"]}},
	{"name": "Flood of Naught", "sheet_time": "1:11", # 55.0
		"new": {"White Mage": ["liturgy_of_the_bell"], "Astrologian": ["macrocosmos"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole"]},
		"carry": {}},
	{"name": "Death Bolt/Wave", "sheet_time": "1:21", # 63.8
		"new": {},
		"carry": {"Scholar": ["sacred_soil"], "Sage": ["kerachole"]}},
	{"name": "Ultima Upsurge", "sheet_time": "1:39", # 81.6
		"new": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole"]},
		"carry": {}},
	{"name": "Death Bolt/Wave", "sheet_time": "1:46", # 88.7
		"new": {},
		"carry": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole"]}},
	{"name": "Ultima Upsurge", "sheet_time": "2:18", # 120.3
		"new": {"Scholar": ["sacred_soil"], "Sage": ["kerachole"]},
		"carry": {}},
]


## Adds a fail for each planned buff the player's job is missing at this hit,
## then lets the hit use up the player's shields.
static func check(index: int, controller: HealerActionController, job_name: String,
		fail_list: FailList) -> void:
	var mechanic: Dictionary = MECHANICS[index]
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
	controller.absorb_hit(HealerAbilities.SHIELDS)
