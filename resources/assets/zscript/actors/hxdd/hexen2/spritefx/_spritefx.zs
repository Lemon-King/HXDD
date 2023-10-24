
// Sprite Reference:
// https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/Client/cl_effect.h
// https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/HCode/fx.hc


class SpriteFX: Actor {
	Default {
		+NOINTERACTION;
        +FORCEXYBILLBOARD;
		+PUFFONACTORS

		Height 0;
		Radius 0;
	}

	States {
		Spawn:
			TNT1 A 0;
			Stop;
	}
}

class SpriteFXParticle: ActorParticle {
	Default {
		+NOINTERACTION;
        +FORCEXYBILLBOARD;
		+PUFFONACTORS

		Height 0;
		Radius 0;
	}

	States {
		Spawn:
			TNT1 A 0;
			Stop;
	}
}

#include "zscript/actors/hxdd/hexen2/spritefx/acidexplosion1.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/acidexplosion2.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/acidmuzzleflash.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/bigexplosion.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/blueexplosion.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/fireboom.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/firecircle.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/firewall1.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/firewall2.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/firewall3.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/firewall4.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/firewall5.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/flamestream.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/pow.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/smallblueflash.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/smallexplosion.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/smallwhiteflash.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/sparks.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/whiteflash.zs"
#include "zscript/actors/hxdd/hexen2/spritefx/whitesmoke.zs"
