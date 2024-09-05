

class BeamFX_Lightning : BeamFX_Node {
	Default {
		RenderStyle "Add";
		Alpha 0.8;

        BeamFX_Node.Length 30;
	}
	
	States {
		Spawn:
			0000 ABCDEF 1 Bright;
			Loop;
	}
}