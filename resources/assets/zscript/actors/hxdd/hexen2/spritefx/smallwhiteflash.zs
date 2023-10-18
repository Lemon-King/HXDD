
class SmallWhiteFlash : SpriteFX {
	Default {
		RenderStyle "Translucent";
		Alpha 0.9;
	}

	States {
		Spawn:
		    SMWH ABC 3 Bright;
			Stop;
	}
}

class SmallWhiteFlashSFX : SmallWhiteFlash {
	Default {
		SeeSound "hexen2/weapons/slash";
		AttackSound "hexen2/weapons/hitwall";
		ActiveSound "hexen2/weapons/gaunt1";
	}
}