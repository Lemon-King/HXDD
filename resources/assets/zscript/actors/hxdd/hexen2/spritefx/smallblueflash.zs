class SmallBlueFlash : SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 0.75;
	}

	States {
		Spawn:
			SMBL ABC 2 Bright;
			Stop;
	}
}