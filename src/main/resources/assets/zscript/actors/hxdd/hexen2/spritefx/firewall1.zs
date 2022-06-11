
class Firewall1: SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 1.0;
	}

	States {
		Spawn:
			FIR1 ABCDEFGHIJKLMNOPQR 2 Bright;
			Stop;
	}
}

class Firewall1Particle: SpriteFXParticle {
	Default {
		RenderStyle "Add";
		Alpha 0.9;
	}

	States {
		Spawn:
			FIR1 ABCDEFGHIJKLMNOPQR 2 Bright;
			Stop;
	}
}