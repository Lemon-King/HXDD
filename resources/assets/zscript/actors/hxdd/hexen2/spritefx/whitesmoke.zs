
// HitFX, will play a sound

class WhiteSmoke : SpriteFX {
	Default {
		RenderStyle "Translucent";
		Alpha 0.5;
	}

	States {
		Spawn:
		    WHT1 ABCDEF 3 Bright;
			Stop;
	}
}

class WhiteSmokeSFX : WhiteSmoke {
	Default {
		SeeSound "hexen2/weapons/slash";
		AttackSound "hexen2/weapons/hitwall";
		ActiveSound "hexen2/weapons/gaunt1";
	}
}