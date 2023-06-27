
class Firewall3: SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 1.0;
	}

	States {
		Spawn:
			FIR3 ABCDE 2 Bright;
			Loop;
	}
}

class Firewall3Particle: SpriteFXParticle {
	Default {
		RenderStyle "Add";
		Alpha 0.9;
	}

	States {
		Spawn:
			FIR3 ABCDE 2 Bright;
			Loop;
	}
}