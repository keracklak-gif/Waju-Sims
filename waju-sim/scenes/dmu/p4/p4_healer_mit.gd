# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## P4 healer mitigation plan, from the DMU healer sheet's "P4 | Kefka Says"
## tab. See HealerMitCheck for what "new" and "carry" mean and the healing
## shield rule. Checked by P4Seq.check_healer_mit() at the hit times in
## p4_anim (each cast's end), which sit ~17s behind the sheet's phase clock.
##
## Left out: the sheet's Scholar "-> Sacred Soil" into the 2nd Grand Cross.
## Soil lasts 15s and the two Grand Crosses are 14.9s apart, so it can't carry.

class_name P4HealerMit

const MECHANICS := [
	{"name": "Grand Cross", "sheet_time": "0:29", "time": 12.4,
		"new": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["spreadlo", "sacred_soil"], "Sage": ["kerachole", "philosophia", "holos"]},
		"carry": {}},
	{"name": "Inferno/Tsunami", "sheet_time": "0:35", "time": 17.4,
		"new": {},
		"carry": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole", "holos"]}},
	{"name": "Grand Cross", "sheet_time": "0:44", "time": 27.3,
		"new": {"White Mage": ["temperance"], "Astrologian": ["neutral_sect"],
			"Scholar": ["expedient", "fey_illumination"], "Sage": ["panhaima"]},
		"carry": {"Sage": ["holos"]}},
	{"name": "Inferno/Tsunami", "sheet_time": "0:49", "time": 32.4,
		"new": {"Astrologian": ["sun_sign"], "Scholar": ["consolation"]},
		"carry": {"White Mage": ["temperance"], "Astrologian": ["neutral_sect"],
			"Scholar": ["expedient", "fey_illumination"], "Sage": ["panhaima"]}},
	{"name": "Grand Cross", "sheet_time": "0:59", "time": 42.4,
		"new": {"White Mage": ["divine_caress"], "Scholar": ["consolation"], "Sage": ["zoe_shields"]},
		"carry": {"White Mage": ["temperance"], "Astrologian": ["neutral_sect", "sun_sign"],
			"Scholar": ["expedient", "fey_illumination"]}},
	{"name": "Flood of Naught", "sheet_time": "1:11", "time": 55.0,
		"new": {"White Mage": ["liturgy_of_the_bell"], "Astrologian": ["macrocosmos"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole"]},
		"carry": {}},
	{"name": "Death Bolt/Wave", "sheet_time": "1:21", "time": 63.8,
		"new": {},
		"carry": {"Scholar": ["sacred_soil"], "Sage": ["kerachole"]}},
	{"name": "Ultima Upsurge", "sheet_time": "1:39", "time": 81.6,
		"new": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole"]},
		"carry": {}},
	{"name": "Death Bolt/Wave", "sheet_time": "1:46", "time": 88.7,
		"new": {},
		"carry": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole"]}},
	{"name": "Ultima Upsurge", "sheet_time": "2:18", "time": 120.3,
		"new": {"Scholar": ["sacred_soil"], "Sage": ["kerachole"]},
		"carry": {}},
]


static func check(index: int, controller: HealerActionController, job_name: String,
		fail_list: FailList) -> void:
	HealerMitCheck.check(MECHANICS, index, controller, job_name, fail_list)
