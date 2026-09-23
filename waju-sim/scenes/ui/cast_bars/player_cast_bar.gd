# Copyright 2026
# All rights reserved.
# This file is released under "GNU General Public License 3.0".
# Please see the LICENSE file that should have been included as part of this package.

## Shows the player's own healer filler-spell cast, driven by ActionBar's
## cast button. Kept separate from the boss-facing CastBar (which lives in
## the "cast_bar" group) so DSR/FRU sequence scripts that fetch the boss's
## cast bar via get_first_node_in_group("cast_bar") never pick this one up.

extends CastBar

class_name PlayerCastBar


func _ready() -> void:
	section_key = "player_cast_bar"
	GameEvents.ui_ready.connect(on_ui_ready)
