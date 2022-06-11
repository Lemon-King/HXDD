
class FlameStream : SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 0.5;
	}

	States {
		Spawn:
			FLAM ABCDEFHIJK 2 Bright;
			Stop;
	}
}

class FlameStreamParticle: SpriteFXParticle {
	Default {
		RenderStyle "Add";
		Alpha 1.0;
	}

	States {
		Spawn:
			FLAM ABCDEFHIJK 2 Bright;
			Stop;
	}
}