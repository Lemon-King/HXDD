class HX2PlayerHead : PlayerChunk {
	vector3 avelocity;

	Default {
		Radius 4;
		Height 4;
		Gravity 0.25;
		+NOBLOCKMAP
		+DROPOFF
		+CANNOTPUSH
		+SKYEXPLODE
		+NOBLOCKMONST
		+NOSKIN
	}
	States {
		Spawn:
			HX2H A 1 A_CheckFloor("Hit");
			Loop;
		Hit:
			HX2H A 16 A_CheckPlayerDone;
			Stop;
	}

	override void BeginPlay() {
		self.avelocity = LemonUtil.GetRandVector3((-6.25, -6.25, -6.25), (6.25, 6.25, 6.25));
	}

	override void Tick() {
		Super.Tick();
		
		self.angle += self.avelocity.x;
		self.pitch += self.avelocity.y;
		self.roll += self.avelocity.z;
	}
}