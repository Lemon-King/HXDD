
class Firewall2: SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 1.0;
	}

	States {
		Spawn:
			FIR2 ABCDEFGHIJK 2 Bright;
			Stop;
	}
}

class Firewall2Particle: SpriteFXParticle {
	Default {
		RenderStyle "Add";
		Alpha 0.9;
	}

	States {
		Spawn:
			FIR2 ABCDEFGHIJK 2 Bright;
			Stop;
	}
}