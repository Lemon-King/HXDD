
class Firewall5 : SpriteFX {
	Default {
		RenderStyle "Add";
		Alpha 1.0;
	}

	States {
		Spawn:
			FI5A ABCDEFGHIJKLMNOPQRSTUVWXYZ 2 Bright;
			FI5B ABCD 2 Bright;
			Stop;
	}
}