class BlueExplosion : SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 0.5;
	}

	States {
		Spawn:
			BLU3 A 2 Bright;
			BLU3 BCDEFGHI 2 Bright;
			Stop;
	}
}