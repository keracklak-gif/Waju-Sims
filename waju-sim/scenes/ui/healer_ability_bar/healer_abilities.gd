# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Healer cooldowns per job, covering the P4 (Kefka Says) healer mitigation
## plan. Recast, cast and buff durations from the official job guide. See
## HealerActionController for what each key means. Order = hotbar slot order.
## A "follow_up" shares its base ability's slot: the button turns into it
## while it's usable (HealerAbilityButton), like FFXIV's replacement actions.

class_name HealerAbilities

const ICON_DIR := "res://assets/common/icons/action_icons/healer/"

const BY_JOB := {
	"White Mage": [
		{"id": "plenary_indulgence", "name": "Plenary Indulgence", "recast": 60.0,
			"grants": {"confession": 10.0}},
		{"id": "temperance", "name": "Temperance", "recast": 120.0,
			"grants": {"temperance": 20.0, "divine_grace": 30.0},
			"follow_up": {"id": "divine_caress", "name": "Divine Caress", "recast": 1.0,
				"requires": "divine_grace", "consumes": true, "grants": {"divine_caress": 10.0}}},
		{"id": "liturgy_of_the_bell", "name": "Liturgy of the Bell", "recast": 180.0,
			"grants": {"liturgy_of_the_bell": 20.0}},
	],
	"Astrologian": [
		{"id": "collective_unconscious", "name": "Collective Unconscious", "recast": 60.0,
			"grants": {"collective_unconscious": 10.0}},
		{"id": "neutral_sect", "name": "Neutral Sect", "recast": 120.0,
			"grants": {"neutral_sect": 20.0, "suntouched": 30.0},
			"follow_up": {"id": "sun_sign", "name": "Sun Sign", "recast": 1.0,
				"requires": "suntouched", "consumes": true, "grants": {"sun_sign": 15.0}}},
		{"id": "helios_conjunction", "name": "Helios Conjunction", "gcd": true,
			"cast_time": 1.5, "grants": {"helios_conjunction": 15.0},
			"boost": {"status": "neutral_sect",
				"grants": {"helios_conjunction": 15.0, "neutral_sect_shield": 30.0}}},
		{"id": "macrocosmos", "name": "Macrocosmos", "gcd": true, "recast": 180.0,
			"grants": {"macrocosmos": 15.0}},
	],
	"Scholar": [
		{"id": "sacred_soil", "name": "Sacred Soil", "recast": 30.0,
			"grants": {"sacred_soil": 15.0}},
		{"id": "recitation", "name": "Recitation", "recast": 60.0,
			"grants": {"recitation": 15.0}},
		# Recitation guarantees the critical heal, which adds Catalyze.
		{"id": "adloquium", "name": "Adloquium", "gcd": true, "cast_time": 2.0,
			"uses": ["recitation"], "grants": {"galvanize": 30.0},
			"boost": {"status": "recitation", "grants": {"galvanize": 30.0, "catalyze": 30.0}}},
		# Spreads the shield for its remaining time. A crit (Catalyze) one is a Spreadlo.
		{"id": "deployment_tactics", "name": "Deployment Tactics", "recast": 90.0,
			"requires": "galvanize", "grants": {"deployed_galvanize": "=galvanize"},
			"boost": {"status": "catalyze", "grants": {"spreadlo": "=catalyze"}}},
		{"id": "expedient", "name": "Expedient", "recast": 120.0,
			"grants": {"expedient": 20.0}},
		{"id": "fey_illumination", "name": "Fey Illumination", "recast": 120.0,
			"grants": {"fey_illumination": 20.0}},
		{"id": "summon_seraph", "name": "Summon Seraph", "recast": 120.0,
			"grants": {"seraph": 22.0},
			"follow_up": {"id": "consolation", "name": "Consolation", "recast": 30.0, "charges": 2,
				"requires": "seraph", "grants": {"consolation": 30.0}}},
	],
	"Sage": [
		{"id": "kerachole", "name": "Kerachole", "recast": 30.0,
			"grants": {"kerachole": 15.0}},
		{"id": "philosophia", "name": "Philosophia", "recast": 180.0,
			"grants": {"philosophia": 20.0}},
		{"id": "holos", "name": "Holos", "recast": 120.0,
			"grants": {"holos": 20.0, "holos_shield": 30.0}},
		{"id": "panhaima", "name": "Panhaima", "recast": 120.0,
			"grants": {"panhaima": 15.0}},
		{"id": "zoe", "name": "Zoe", "recast": 90.0, "grants": {"zoe": 30.0}},
		{"id": "eukrasia", "name": "Eukrasia", "gcd": true, "gcd_recast": 1.0,
			"grants": {"eukrasia": -1.0},
			"follow_up": {"id": "eukrasian_prognosis_ii", "name": "Eukrasian Prognosis II",
				"gcd": true, "gcd_recast": 1.5, "requires": "eukrasia", "consumes": true,
				"uses": ["zoe"], "grants": {"eukrasian_prognosis": 30.0},
				"boost": {"status": "zoe", "grants": {"zoe_shields": 30.0}}}},
	],
}

## Barriers - each damaging hit uses them up.
const SHIELDS := ["divine_caress", "neutral_sect_shield", "galvanize", "catalyze",
	"deployed_galvanize", "spreadlo", "consolation", "holos_shield",
	"eukrasian_prognosis", "zoe_shields"]

## Buff names for tooltips and fail messages, following the healer sheet's wording.
const STATUS_NAMES := {
	"confession": "Plenary Indulgence",
	"temperance": "Temperance",
	"divine_grace": "Divine Grace",
	"divine_caress": "Divine Caress",
	"liturgy_of_the_bell": "Liturgy of the Bell",
	"collective_unconscious": "Collective Unconscious",
	"neutral_sect": "Neutral Sect",
	"suntouched": "Suntouched",
	"sun_sign": "Sun Sign",
	"helios_conjunction": "Helios Conjunction",
	"neutral_sect_shield": "Neutral Sect Shield",
	"macrocosmos": "Macrocosmos",
	"sacred_soil": "Sacred Soil",
	"recitation": "Recitation",
	"galvanize": "Galvanize",
	"catalyze": "Catalyze",
	"deployed_galvanize": "Deployment Tactics",
	"spreadlo": "Spreadlo",
	"expedient": "Expedient",
	"fey_illumination": "Fey Illumination",
	"seraph": "Seraph",
	"consolation": "Seraph (Consolation)",
	"kerachole": "Kerachole",
	"philosophia": "Philosophia",
	"holos": "Holos",
	"holos_shield": "Holos Shield",
	"panhaima": "Panhaima",
	"zoe": "Zoe",
	"eukrasia": "Eukrasia",
	"eukrasian_prognosis": "Eukrasian Prognosis II",
	"zoe_shields": "Zoe Shields",
}


## The job's hotbar abilities, one per slot (follow-ups nested inside).
static func for_job(job_name: String) -> Array:
	return BY_JOB.get(job_name, [])


## Every ability the job can use, follow-ups included.
static func all_for_job(job_name: String) -> Array:
	var all := []
	for ability: Dictionary in for_job(job_name):
		all.append(ability)
		if ability.has("follow_up"):
			all.append(ability["follow_up"])
	return all


static func icon_path(ability: Dictionary) -> String:
	return icon_path_for_id(ability["id"])


static func icon_path_for_id(id: String) -> String:
	return ICON_DIR + id + "_icon.png"


static func status_name(status: String) -> String:
	return STATUS_NAMES.get(status, status.capitalize())
