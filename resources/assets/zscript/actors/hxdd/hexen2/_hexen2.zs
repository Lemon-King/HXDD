
// https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/HCode/precache.hc
// https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/Client/cl_effect.h
// lighting: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2MP/code/CL_MAIN.C#L727


// SpriteFX
#include "zscript/actors/hxdd/hexen2/spritefx/_spritefx.zs"

// Hexen 2 Player Classes
#include "zscript/actors/hxdd/hexen2/players/_shared.zs"
#include "zscript/actors/hxdd/hexen2/players/paladinplayer.zs"
#include "zscript/actors/hxdd/hexen2/players/crusaderplayer.zs"
#include "zscript/actors/hxdd/hexen2/players/assassinplayer.zs"
#include "zscript/actors/hxdd/hexen2/players/necromancerplayer.zs"
#include "zscript/actors/hxdd/hexen2/players/succubusplayer.zs"

// Hexen 2 Weapon Base
#include "zscript/actors/hxdd/hexen2/weapons/weaponbase.zs"

// Paladin Weapons
#include "zscript/actors/hxdd/hexen2/weapons/paladingauntlets.zs"           // NEEDS GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/paladinvorpalsword.zs"         // NEEDS GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/paladinaxe.zs"                 // NEEDS GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/paladinpurifier.zs"            // NEEDS HOMING TUNING, GL LIGHTING, ICON

// Crusader Weapons
#include "zscript/actors/hxdd/hexen2/weapons/crusaderwarhammer.zs"          // NEEDS POWERED, POLISH PASS, GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/crusadericemace.zs"            // NEEDS POWERED, POLISH PASS, GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/crusadermeteorstaff.zs"        // NEEDS POWERED, POLISH PASS, GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/crusaderlightbringer.zs"       // NEEDS BEAM BOUNCE FIX FOR GROUND, POLISH PASS, GL LIGHTING, ICON (BUGGY)

// Necromancer Weapons
#include "zscript/actors/hxdd/hexen2/weapons/necromancersickle.zs"          // NEEDS POWERED, POLISH PASS, GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/necromancerspellbook.zs"       // NEEDS POWERED?, HOMING TUNING, POLISH PASS, GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/necromancerravenstaff.zs"      // NEEDS IMPLEMENTION

// Assassin Weapons
#include "zscript/actors/hxdd/hexen2/weapons/assassinpunchdagger.zs"        // NEEDS POWERED, POLISH PASS, GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/assassincrossbow.zs"           // NEEDS POLISH PASS, GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/assassingrenades.zs"           // NEEDS POLISH PASS, GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/assassinstaffofset.zs"         // NEEDS IMPLEMENTION

// Succubus Weapons
#include "zscript/actors/hxdd/hexen2/weapons/succubusbloodrain.zs"          // NEEDS POWERED, GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/succubusacidrune.zs"           // NEEDS POLISH PASS, GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/succubusfirestorm.zs"          // NEEDS POLISH PASS, GL LIGHTING, ICON
#include "zscript/actors/hxdd/hexen2/weapons/succubustempeststaff.zs"       // NEEDS IMPLEMENTION

// Inventory
#include "zscript/actors/hxdd/hexen2/inventory/pickups.zs"

// Pickups
#include "zscript/actors/hxdd/hexen2/pickups/powerupsphere.zs"