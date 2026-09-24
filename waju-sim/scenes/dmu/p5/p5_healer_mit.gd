# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## P5 healer mitigation plan, from the DMU healer sheet's "P5 | Kefka
## Reimagined" tab. See HealerMitCheck for what "new" and "carry" mean and the
## healing shield rule. Checked by P5Seq.check_healer_mit() at the first hit of
## each mechanic in p5_seq, which sits ~43s behind the sheet's phase clock.
## Each odd Forsaken hit lands with its fors_N_tele, each Forsaken Bonds stack
## with its fors_N_hit.
##
## Left out: the sheet's rows with no healer plan (Stray Entropy and the 3rd
## Fell Forces, where healers just watch the tanks), and Sage's "-> Panhaima"
## into the 7th Forsaken hit. Panhaima lasts 15s and has to be up for the 3rd
## hit, 16s earlier, so it can't carry.
##
## "Seraph" in the sheet is Seraph's Consolation shield.

class_name P5HealerMit

const MECHANICS := [
	{"name": "Ultima Repeater", "sheet_time": "0:49", # p5_seq 5.7
		"new": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["spreadlo", "sacred_soil"], "Sage": ["zoe_shields", "holos", "kerachole"]},
		"carry": {}},
	{"name": "Fell Forces", "sheet_time": "0:54", # 11.0
		"new": {},
		"carry": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["holos", "kerachole"]}},
	{"name": "Chaotic Flood", "sheet_time": "1:06", # 23.8
		"new": {"White Mage": ["temperance"], "Astrologian": ["neutral_sect"],
			"Scholar": ["expedient"], "Sage": ["panhaima"]},
		"carry": {"Sage": ["holos"]}},
	{"name": "Maddening Orchestra", "sheet_time": "1:18", # 36.5
		"new": {"White Mage": ["divine_caress"], "Astrologian": ["sun_sign"],
			"Scholar": ["sacred_soil", "fey_illumination"], "Sage": ["kerachole"]},
		"carry": {"White Mage": ["temperance"], "Scholar": ["expedient"]}},
	{"name": "Fell Forces", "sheet_time": "1:31", # 47.9
		"new": {},
		"carry": {"Astrologian": ["sun_sign"], "Scholar": ["sacred_soil", "fey_illumination"],
			"Sage": ["kerachole"]}},
	{"name": "Celestriad", "sheet_time": "1:49", # 66.7
		"new": {"Scholar": ["consolation"]},
		"carry": {}},
	{"name": "Ultima Repeater", "sheet_time": "2:11", # 87.6
		"new": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole"]},
		"carry": {}},
	{"name": "Fell Forces", "sheet_time": "2:16", # 93.1
		"new": {},
		"carry": {"White Mage": ["confession"], "Astrologian": ["collective_unconscious"],
			"Scholar": ["sacred_soil"], "Sage": ["kerachole"]}},
	{"name": "Maddening Orchestra", "sheet_time": "2:51", # 128.7
		"new": {"Scholar": ["sacred_soil"], "Sage": ["kerachole"]},
		"carry": {}},
	{"name": "Forsaken (1st hit)", "sheet_time": "3:20", # 158.0
		"new": {"White Mage": ["temperance"],
			"Astrologian": ["neutral_sect", "collective_unconscious"],
			"Scholar": ["spreadlo", "fey_illumination", "sacred_soil"],
			"Sage": ["zoe_shields", "holos", "kerachole"]},
		"carry": {}},
	{"name": "Forsaken Bonds (2nd hit)", "sheet_time": "3:25", # 163.0
		"new": {"White Mage": ["liturgy_of_the_bell"], "Scholar": ["seraphism"],
			"Sage": ["philosophia"]},
		"carry": {"White Mage": ["temperance"],
			"Astrologian": ["neutral_sect", "collective_unconscious"],
			"Scholar": ["fey_illumination", "sacred_soil"], "Sage": ["holos", "kerachole"]}},
	{"name": "Forsaken (3rd hit)", "sheet_time": "3:28", # 166.0
		"new": {"Astrologian": ["macrocosmos"], "Scholar": ["expedient"], "Sage": ["panhaima"]},
		"carry": {"White Mage": ["temperance"],
			"Astrologian": ["neutral_sect", "collective_unconscious"],
			"Scholar": ["fey_illumination", "sacred_soil"], "Sage": ["holos", "kerachole"]}},
	{"name": "Forsaken Bonds (4th hit)", "sheet_time": "3:34", # 171.0
		"new": {},
		"carry": {"White Mage": ["temperance"], "Astrologian": ["neutral_sect"],
			"Scholar": ["fey_illumination", "expedient"], "Sage": ["holos", "panhaima"]}},
	{"name": "Forsaken (5th hit)", "sheet_time": "3:37", # 174.0
		"new": {"White Mage": ["divine_caress"], "Astrologian": ["sun_sign"]},
		"carry": {"White Mage": ["temperance"], "Scholar": ["expedient"],
			"Sage": ["holos", "panhaima"]}},
	{"name": "Forsaken Bonds (6th hit)", "sheet_time": "3:42", # 179.0
		"new": {"White Mage": ["confession"]},
		"carry": {"Astrologian": ["sun_sign"], "Scholar": ["expedient"], "Sage": ["panhaima"]}},
	{"name": "Forsaken (7th hit)", "sheet_time": "3:45", # 182.0
		"new": {"Scholar": ["consolation"]},
		"carry": {"White Mage": ["confession"], "Astrologian": ["sun_sign"]}},
	{"name": "Forsaken Bonds (8th hit)", "sheet_time": "3:50", # 187.0
		"new": {"Scholar": ["consolation", "sacred_soil"], "Sage": ["kerachole"]},
		"carry": {"White Mage": ["confession"], "Astrologian": ["sun_sign"]}},
]


static func check(index: int, controller: HealerActionController, job_name: String,
		fail_list: FailList) -> void:
	HealerMitCheck.check(MECHANICS[index], controller, job_name, fail_list)
