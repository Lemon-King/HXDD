
class SmallExplosion: SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 0.75;
	}

	States {
		Spawn:
            SMEX ABCDEFGHIJKL 3 Bright;
			Stop;
	}
}