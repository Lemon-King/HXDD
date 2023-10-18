
// HitFX, will play a sound

class WhiteFlash : SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 0.8;
		SeeSound "hexen2/weapons/slash";
		AttackSound "hexen2/weapons/hitwall";
		ActiveSound "hexen2/weapons/gaunt1";
	}

	States {
		Spawn:
		    GRYS ABCDE 3 Bright;
			Stop;
	}
}