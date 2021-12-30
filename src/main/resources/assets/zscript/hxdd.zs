
// Uses Gutamatics: https://gitlab.com/Gutawer/gzdoom-gutamatics/
#include "zscript/lib/Gutamatics/include.zsc"

#include "zscript/worldhandler.zs"

#include "zscript/actors/hxddplayerpawn.zs"

// Player Classes
#include "zscript/actors/hxdd/classes/hxddhereticplayer.zs"
#include "zscript/actors/hxdd/classes/hxddfighterplayer.zs"
#include "zscript/actors/hxdd/classes/hxddclericplayer.zs"
#include "zscript/actors/hxdd/classes/hxddmageplayer.zs"

// Player Weapons and Ammo
#include "zscript/actors/hxdd/items/hereticammo.zs"
#include "zscript/actors/hxdd/items/hereticweapons.zs"
#include "zscript/actors/hxdd/items/hexenammo.zs"
#include "zscript/actors/hxdd/items/hexenweapons.zs"

// Mobs
#include "zscript/actors/hxdd/mobs/hereticaltspawns.zs"
#include "zscript/actors/hxdd/mobs/hereticmobs.zs"
#include "zscript/actors/hxdd/mobs/hxddfighterboss.zs"
#include "zscript/actors/hxdd/mobs/hxddclericboss.zs"
#include "zscript/actors/hxdd/mobs/hxddmageboss.zs"

// Spawning Scripts
#include "zscript/actors/hxdd/cvaraltspawnselector.zs"
#include "zscript/actors/hxdd/multispawner.zs"
#include "zscript/actors/hxdd/doomednums_compat.zs"
#include "zscript/actors/hxdd/spawnnums_compat.zs"


// REF: https://github.com/videogamepreservation/hexen2/tree/master/H2MP/hcode
#include "zscript/actors/player/progression.zs"

#include "zscript/actors/hexen2/paladinplayer.zs"
#include "zscript/actors/hexen2/crusaderplayer.zs"
#include "zscript/actors/hexen2/assassinplayer.zs"
#include "zscript/actors/hexen2/necromancerplayer.zs"
#include "zscript/actors/hexen2/succubusplayer.zs"

#include "zscript/actors/hexen2/baseweapons.zs"

// Paladin Weapons
#include "zscript/actors/hexen2/weapons/paladingauntlets.zs"
#include "zscript/actors/hexen2/weapons/paladinvorpalsword.zs"
#include "zscript/actors/hexen2/weapons/paladinaxe.zs"

// Crusader Weapons
#include "zscript/actors/hexen2/weapons/crusaderwarhammer.zs"
#include "zscript/actors/hexen2/weapons/crusadericemace.zs"
#include "zscript/actors/hexen2/weapons/crusadermeteorstaff.zs"

// Assassin Weapons
#include "zscript/actors/hexen2/weapons/assassinpunchdagger.zs"
#include "zscript/actors/hexen2/weapons/assassincrossbow.zs"
#include "zscript/actors/hexen2/weapons/assassingrenades.zs"

// Necromancer Weapons
#include "zscript/actors/hexen2/weapons/necromancersickle.zs"
#include "zscript/actors/hexen2/weapons/necromancerspellbook.zs"    // Magic Missile & Bone Shards

// Succubus Weapons
#include "zscript/actors/hexen2/weapons/succubusbloodrain.zs"