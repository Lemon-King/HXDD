
// HitFX, will play a sound

class Sparks : SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 0.8;
	}

	States {
		Spawn:
		    SPAR ABCDEFGHI 3 Bright;
			Stop;
	}
}

class SparksSFX : Sparks {
	Default {
		SeeSound "hexen2/weapons/slash";
		AttackSound "hexen2/weapons/hitwall";
		ActiveSound "hexen2/weapons/gaunt1";
	}
}