class FireCircle: SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 1.0;
	}

	States {
		Spawn:
			FCIR ABCDEF 2 Bright;
			Stop;
	}
}