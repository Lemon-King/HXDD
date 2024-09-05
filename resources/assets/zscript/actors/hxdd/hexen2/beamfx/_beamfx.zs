
// Beam Helper Actor

class BeamFX : Actor {
	Default {
		+NOINTERACTION;
		+NOGRAVITY;
	}

	String clsNode;
	int maxLength;
	int flags;
	Array<BeamFX_Node> list;

	vector3 aVec;
	vector3 aRotate;

	override void BeginPlay() {
		Super.BeginPlay();

		if (self.clsNode) {
			self.CreateNewBeam();
		}
	}

	override void Tick() {
		Super.Tick();
	
		self.aRotate = LemonUtil.ModVector3(self.aRotate + (self.aVec * TICRATEFRAC), 360);
	
		HXDD_GM_Matrix parentRotationMatrix = HXDD_GM_Matrix.fromEulerAngles(self.angle, self.pitch, self.roll);
	
		for (int i = 0; i < self.list.Size(); i++) {
			BeamFX_Node node = self.list[i];

			[node.angle, node.pitch, node.roll] = LemonUtil.GetFacingWithRotation((self.angle, self.pitch, self.roll), self.aRotate);

			Vector3 growthDirection = parentRotationMatrix.multiplyVector3(node.facing).asVector3();
			Vector3 localOffset = growthDirection * (i * node.length);

			node.SetOrigin(self.pos + localOffset, false);
		}
	}

	override void OnDestroy() {
		self.Clear();
		Super.OnDestroy();
	}

	void SetFX(String next, vector3 rotation = (0,0,0), int nextLength = 500, int flags = TRF_THRUACTORS) {
		self.clsNode = next;
		self.maxLength = nextLength;
		self.aVec = rotation;
		self.flags = flags;

		// clear all
		self.Clear();
		
		// Regenerate
		self.CreateNewBeam();
	}

	void CreateNewBeam() {
		class<BeamFX_Node> exists = self.clsNode;
		if (!exists || !(exists is "BeamFX_Node")) {
			console.printf("BeamFX: Invalid class %[s]!", self.clsNode);
			return;
		}

		HXDD_GM_Matrix facingMatrix = HXDD_GM_Matrix.fromEulerAngles(self.angle, self.pitch, self.roll);


		double length = self.maxLength;

		FLineTracedata trace;
		self.LineTrace(self.angle, self.maxLength, self.pitch, self.flags, 0, data: trace);
		Vector3 newpos = trace.HitLocation;
		if (trace.HitType != TRACE_HitNone) {
			length = (self.pos - trace.HitLocation).Length();
		}
		int fxLength = GetDefaultByType(exists).length;
		int count = ceil(length / fxLength);

		for (int i = 0; i < count; i++) {			
			Vector3 localOffset = (i, 0, 0);
			Vector3 facingOffset = facingMatrix.multiplyVector3(localOffset, HXDD_GM_Vector_Direction).asVector3();

			BeamFX_Node node = BeamFX_Node(Spawn(self.clsNode, self.pos + facingOffset, true));
			self.list.Push(node);
		}
	}

	void Clear() {
		for (int i = 0; i < self.list.Size(); i++) {
			BeamFX_Node node = self.list[i];
			node.Destroy();
		}
	}
}

class BeamFX_Node : Actor {
	double length;
	vector3 facing;

	property Length: length;
	property Facing: facing;

	Default {
		+NOINTERACTION;
		+NOGRAVITY;

		BeamFX_Node.Length 1;
		BeamFX_Node.Facing (1,0,0);
	}
	
	States {
		Spawn:
			TNT0 A 1;
			Loop;
	}
}


#include "zscript/actors/hxdd/hexen2/beamfx/lightning.zs"