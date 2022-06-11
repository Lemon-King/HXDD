
class Firewall4: SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 1.0;
	}

	States {
		Spawn:
			FI4A ABCDEFGHIJKLMNOPQRSTUVWXYZ 2 Bright;
			FI4B ABC 2 Bright;
			Stop;
	}
}