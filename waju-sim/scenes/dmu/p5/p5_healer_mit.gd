# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## P5 healer mitigation plan, from the DMU healer sheet's "P5 | Kefka
## Reimagined" tab, laid over every AoE hit in p5_seq. See HealerMitCheck for
## what "new" and "carry" mean and the healing shield rules. Checked by
## P5Seq.check_healer_mit() at each hit's "time", which sits ~43s behind the
## sheet's phase clock. A sheet row's plan sits on its mechanic's first hit.
## Each odd Forsaken hit lands with its fors_N_tele, each Forsaken Bonds stack
## with its fors_N_hit.
##
## Left out of the plan: Sage's "-> Panhaima" into the 7th Forsaken hit.
## Panhaima lasts 15s and has to be up for the 3rd hit, 16s earlier, so it
## can't carry. Stray Entropy and the last Fell Forces have no healer plan
## (healers just watch the tanks), so they only check the healing shield.
##
## "Seraph" in the sheet is Seraph's Consolation shield.

class_name P5HealerMit

## The Fell Forces auto skipped when starting at Flood (auto_hit_pre_flood).
const PRE_FLOOD_AUTO := 3

const MECHANICS := [
	{"name": "Ultima Repeater", "sheet_time": "0:49", "time": 5.7,
		"new": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["spreadlo", "sacred_soil"], "Sage": ["zoe_shields", "holos", "kerachole"]},
		"carry": {}},
	{"name": "Fell Forces", "sheet_time": "0:54", "time": 11.0,
		"new": {},
		"carry": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["holos", "kerachole"]}},
	{"name": "Fell Forces (2nd auto)", "time": 14.2, "new": {}, "carry": {}},
	{"name": "Fell Forces (3rd auto)", "time": 17.3, "new": {}, "carry": {}},
	{"name": "Chaotic Flood", "sheet_time": "1:06", "time": 23.8,
		"new": {"White Mage": ["temperance"], "Astrologian": ["neutral_sect"],
			"Scholar": ["expedient"], "Sage": ["panhaima"]},
		"carry": {"Sage": ["holos"]}},
	{"name": "Chaotic Flood (2nd hit)", "time": 24.8, "new": {}, "carry": {}},
	{"name": "Chaotic Flood (3rd hit)", "time": 25.8, "new": {}, "carry": {}},
	{"name": "Chaotic Flood (4th hit)", "time": 26.8, "new": {}, "carry": {}},
	{"name": "Maddening Orchestra", "sheet_time": "1:18", "time": 36.5,
		"new": {"White Mage": ["divine_caress"], "Astrologian": ["sun_sign"],
			"Scholar": ["sacred_soil", "fey_illumination"], "Sage": ["kerachole"]},
		"carry": {"White Mage": ["temperance"], "Scholar": ["expedient"]}},
	{"name": "Maddening Orchestra (2nd hit)", "time": 39.7, "new": {}, "carry": {}},
	{"name": "Maddening Orchestra (3rd hit)", "time": 43.2, "new": {}, "carry": {}},
	{"name": "Fell Forces", "sheet_time": "1:31", "time": 47.9,
		"new": {},
		"carry": {"Astrologian": ["sun_sign"], "Scholar": ["sacred_soil", "fey_illumination"],
			"Sage": ["kerachole"]}},
	{"name": "Fell Forces (2nd auto)", "time": 51.0, "new": {}, "carry": {}},
	{"name": "Celestriad", "sheet_time": "1:49", "time": 66.7,
		"new": {"Scholar": ["consolation"]},
		"carry": {}},
	{"name": "Celestriad (2nd towers)", "time": 73.0, "new": {}, "carry": {}},
	{"name": "Celestriad (3rd towers)", "time": 79.3, "new": {}, "carry": {}},
	{"name": "Ultima Repeater", "sheet_time": "2:11", "time": 87.6,
		"new": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole"]},
		"carry": {}},
	{"name": "Fell Forces", "sheet_time": "2:16", "time": 93.1,
		"new": {},
		"carry": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole"]}},
	{"name": "Fell Forces (2nd auto)", "time": 96.1, "new": {}, "carry": {}},
	{"name": "Stray Entropy", "sheet_time": "2:42", "time": 118.4, "new": {}, "carry": {}},
	{"name": "Maddening Orchestra", "sheet_time": "2:51", "time": 128.7,
		"new": {"Scholar": ["sacred_soil"], "Sage": ["kerachole"]},
		"carry": {}},
	{"name": "Maddening Orchestra (2nd hit)", "time": 131.9, "new": {}, "carry": {}},
	{"name": "Maddening Orchestra (3rd hit)", "time": 135.4, "new": {}, "carry": {}},
	{"name": "Fell Forces", "sheet_time": "3:03", "time": 140.0, "new": {}, "carry": {}},
	{"name": "Fell Forces (2nd auto)", "time": 143.1, "new": {}, "carry": {}},
	{"name": "Fell Forces (3rd auto)", "time": 146.2, "new": {}, "carry": {}},
	{"name": "Forsaken (1st hit)", "sheet_time": "3:20", "time": 158.0,
		"new": {"White Mage": ["temperance"],
			"Astrologian": ["neutral_sect", "collective_unconscious"],
			"Scholar": ["spreadlo", "fey_illumination", "sacred_soil"],
			"Sage": ["zoe_shields", "holos", "kerachole"]},
		"carry": {}},
	{"name": "Forsaken Bonds (2nd hit)", "sheet_time": "3:25", "time": 163.0,
		"new": {"White Mage": ["liturgy_of_the_bell"], "Scholar": ["seraphism"],
			"Sage": ["philosophia"]},
		"carry": {"White Mage": ["temperance"],
			"Astrologian": ["neutral_sect", "collective_unconscious"],
			"Scholar": ["fey_illumination", "sacred_soil"], "Sage": ["holos", "kerachole"]}},
	{"name": "Forsaken (3rd hit)", "sheet_time": "3:28", "time": 166.0,
		"new": {"Astrologian": ["macrocosmos"], "Scholar": ["expedient"], "Sage": ["panhaima"]},
		"carry": {"White Mage": ["temperance"],
			"Astrologian": ["neutral_sect", "collective_unconscious"],
			"Scholar": ["fey_illumination", "sacred_soil"], "Sage": ["holos", "kerachole"]}},
	{"name": "Forsaken Bonds (4th hit)", "sheet_time": "3:34", "time": 171.0,
		"new": {},
		"carry": {"White Mage": ["temperance"], "Astrologian": ["neutral_sect"],
			"Scholar": ["fey_illumination", "expedient"], "Sage": ["holos", "panhaima"]}},
	{"name": "Forsaken (5th hit)", "sheet_time": "3:37", "time": 174.0,
		"new": {"White Mage": ["divine_caress"], "Astrologian": ["sun_sign"]},
		"carry": {"White Mage": ["temperance"], "Scholar": ["expedient"],
			"Sage": ["holos", "panhaima"]}},
	{"name": "Forsaken Bonds (6th hit)", "sheet_time": "3:42", "time": 179.0,
		"new": {"White Mage": ["confession"]},
		"carry": {"Astrologian": ["sun_sign"], "Scholar": ["expedient"], "Sage": ["panhaima"]}},
	{"name": "Forsaken (7th hit)", "sheet_time": "3:45", "time": 182.0,
		"new": {"Scholar": ["consolation"]},
		"carry": {"White Mage": ["confession"], "Astrologian": ["sun_sign"]}},
	{"name": "Forsaken Bonds (8th hit)", "sheet_time": "3:50", "time": 187.0,
		"new": {"Scholar": ["consolation", "sacred_soil"], "Sage": ["kerachole"]},
		"carry": {"White Mage": ["confession"], "Astrologian": ["sun_sign"]}},
]


static func check(index: int, controller: HealerActionController, job_name: String,
		fail_list: FailList) -> void:
	HealerMitCheck.check(MECHANICS, index, controller, job_name, fail_list)
