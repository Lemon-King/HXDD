// https://github.com/videogamepreservation/hexen2/blob/master/H2MP/hcode/sunstaff.hc

class CWeapLightbringerPiece: WeaponPiece {
	Default {
		Inventory.PickupSound "misc/w_pkup";
		Inventory.PickupMessage "$TXT_LIGHTBRINGER_PIECE";
		Inventory.RestrictedTo "CrusaderPlayer";
		WeaponPiece.Weapon "CWeapLightbringer";
		+FLOATBOB
	}
}

class CWeapLightbringerPiece1: CWeapLightbringerPiece {
	Default {
		WeaponPiece.Number 1;
	}
	States {
        Spawn:
            PKUP A -1 Bright;
            Stop;
	}
}

class CWeapLightbringerPiece2: CWeapLightbringerPiece {
	Default {
		WeaponPiece.Number 2;
	}
	States {
        Spawn:
            PKUP A -1 Bright;
            Stop;
	}
}

class CWeapLightbringer: CrusaderWeapon {
	CWeapLightbringer_Node beamOrigin;
	CWeapLightbringer_Ray rays[3];

	double a_roll;

	Default {
		+BLOODSPLATTER;
		+FLOATBOB;

		+WEAPON.PRIMARY_USES_BOTH;

        Health 2;

		Weapon.SelectionOrder 2900;
		Weapon.AmmoType1 "Mana1";
		Weapon.AmmoType2 "Mana2";
		Weapon.AmmoUse1 1;
		Weapon.AmmoUse2 1;
		Weapon.AmmoGive 20;
		Weapon.KickBack 150;
		//Weapon.YAdjust 40;
		Inventory.PickupMessage "$TXT_WEAPON_LIGHTBRINGER";
		Inventory.PickupSound "WeaponBuild";
		Tag "$TAG_CWEAPLIGHTBRINGER";
	}

	States {
		Select:
			SSEL ABCDEFGHIJKLMN 2 Offset(0, 32);
			SIDL A 0 A_OnCompleteSelect;
			Goto Ready;
		Deselect:
			SIDL A 0 A_ClearRayArrays(true);
			SSEL NMLKJIHGFEDCBA 2;
			TNT1 A 0 A_Lower(100);
			Loop;
		Ready:
			SIDL ABCDEFGHIJKLMNOPQRSTUVWXYZ 2 A_WeaponReady;
			SIDE ABCDE 2 A_WeaponReady;
			Loop;
		Fire:
			SUNF ABCD 2;
			Goto Fire_Cycle;
		Fire_Cycle:
			SCYC ABCDEFGHIJ 2 A_TryFire();
			SCYC J 0 A_ReFire("Fire_Cycle");
			Goto Fire_Settle;
		Fire_Settle:
			SSTL A 0 A_ClearRayArrays;
			SSTL ABCDE 2;
			SIDL A 0;
			Goto Ready;
    }

	action void A_DecideAttack() {
        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);
		if (isPowered) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire_Power"));
		} else {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire_Normal"));
		}
	}

	action void A_TryFire() {
		if (Player == null) {
			return;
		}
		if (!(Player.cmd.buttons & BT_ATTACK)) {
			Player.SetPsprite(PSP_WEAPON, Player.ReadyWeapon.FindState("Fire_Settle"));
		}
		CWeapLightbringer weapon = CWeapLightbringer(Player.ReadyWeapon);
		if (weapon.Cooldown(Player.ReadyWeapon)) {
			return;
		}
        bool isPowered = Player.mo.FindInventory("PowerWeaponLevel2", true);
		if (isPowered && weapon.AmmoUse1 != 2) {
			weapon.AmmoUse1 = 2;
			weapon.AmmoUse2 = 2;
		} else if (!isPowered) {
            // Uses about 1/3rd Mana per tick
			//weapon.AmmoUse1 = 0.35;
			//weapon.AmmoUse2 = 0.35;
            weaponspecial = (weaponspecial + 1) % 3;
            if (weaponspecial == 0) {
                weapon.AmmoUse1 = 1;
                weapon.AmmoUse2 = 1;
            } else {
                weapon.AmmoUse1 = 0;
                weapon.AmmoUse2 = 0;
            }
		}
		if (weapon && !weapon.DepleteAmmo(weapon.bAltFire)) {
			return;
		}

		weapon.a_roll += 3;
		
		int damage = 7;
		double distance = 750.0;

		A_TraceBeam(0, startDistance: distance, damage: damage);
		if (isPowered) {
			damage = 17;
			distance = 1000.0;
			// add two more beams
			vector3 dir = (AngleToVector(self.Player.mo.angle - 45.0, cos(self.Player.mo.pitch)), -sin(self.Player.mo.pitch));
			A_TraceBeam(1, startDir: dir, lroffset: 15, startDistance: distance, damage: damage);
			dir = (AngleToVector(self.Player.mo.angle + 45.0, cos(self.Player.mo.pitch)), -sin(self.Player.mo.pitch));
			A_TraceBeam(2, startDir: dir, lroffset: -15, startDistance: distance, damage: damage);
		}
	}

	action void A_OnCompleteSelect() {
		CWeapLightbringer weapon = CWeapLightbringer(Player.ReadyWeapon);
		weapon.a_roll = 0;

		for (int i = 0; i < 3; i++) {
			weapon.rays[i] = new("CWeapLightbringer_Ray");
			weapon.rays[i].point.Reserve(0);
			for (int j = 0; j < 3; j++) {
				weapon.rays[i].beams[j].Reserve(0);
			}
		}
		A_Raise(100);
	}

	action void A_ClearRayArrays(bool Deselect = false) {
		CWeapLightbringer weapon = CWeapLightbringer(Player.ReadyWeapon);
		for (int r = 0; r < 3; r++) {
			for (int i = 0; i < weapon.rays[r].point.Size(); i++) {
				if (weapon.rays[r].point[i]) {
					weapon.rays[r].point[i].Remove();
				}
			}
			weapon.rays[r].point.Clear();
			for (int i = 0; i < 3; i++) {
				for (int n = 0; n < weapon.rays[r].beams[i].Size(); n++) {
					if (weapon.rays[r].beams[i][n]) {
						weapon.rays[r].beams[i][n].Remove();
					}
				}
				weapon.rays[r].beams[i].Clear();
			}
			if (Deselect) {
				weapon.rays[r] = null;
			}
		}
		weapon.beamOrigin.Remove();
		if (Deselect) {
			weapon.beamOrigin = null;
		}
	}

	// Needs a MASSIVE Cleanup!
    action void A_TraceBeam(int indexBeam, vector3 startDir = (0,0,0), double lroffset = 0.0, double startDistance = 750.0, double damage = 7) {
		vector3 nextPos = (0,0,0);
		vector3 dir = startDir;
		double distance = startDistance;

		CWeapLightbringer weapon = CWeapLightbringer(Player.ReadyWeapon);

        // Beam fires from source v3 to dest via tracer
		let tracer = new("CWeapLightbringerTrace");
		if (!tracer) {
			console.printf("CWeapLightbringer: Failed to create CWeapLightbringerTrace.");
			return;
		}
        if (nextPos == (0,0,0)) {

            // Get source from owner
			if (dir == (0,0,0)) {
				dir = (AngleToVector(self.Player.mo.angle, cos(self.Player.mo.pitch)), -sin(self.Player.mo.pitch));
			}
			nextPos = self.Player.mo.pos;
			nextPos.z += player.viewz - pos.z - 4;
			nextPos += dir * 15;

			if (lroffset != 0.0) {
				double a = angle;
				double p = Clamp(pitch + 0, -90, 90);
				double r = roll;
				let mat = HXDD_GM_Matrix.fromEulerAngles(a, p, r);
				mat = mat.multiplyVector3((0, lroffset * 0.5, 0));
				vector3 offsetPos = mat.asVector3(false);
				nextPos = level.vec3offset(offsetPos, nextPos);
			}

			// Pre trace to get reticle dir from HitVector
			tracer.Trace(nextPos, self.player.mo.CurSector, dir, distance, TRACE_HitSky);
			if (tracer.bFinished) {
				nextPos.z -= 4;
				dir = tracer.Results.HitVector;

				tracer.bFinished = false;
			}
		}

		// hack to fix angles
		if (!weapon.beamOrigin) {
			weapon.beamOrigin = CWeapLightbringer_Node(Spawn("CWeapLightbringer_Node"));
			weapon.beamOrigin.SetOrigin(nextPos, false);
		} else {
			weapon.beamOrigin.SetOrigin(nextPos, true);
		}

		for (int i = 0; i < 3; i++) {
			if (distance > 0.0) {
				tracer = new("CWeapLightbringerTrace");
				tracer.owner = weapon.owner;
				
				Sector sourceSector = self.player.mo.CurSector;
				CWeapLightbringer_Node point = null;
				if (i > 0) {
					point = weapon.rays[indexBeam].point[i - 1];
					sourceSector = point.CurSector;
				}
				tracer.Trace(nextPos, sourceSector, dir, distance, TRACE_ReportPortals | TRACE_HitSky);
				if (tracer.bFinished) {
					vector3 HitPos = tracer.Results.HitPos;
					vector3 normal = tracer.GetSurfaceNormal();
					dir = LemonUtil.v3Bounce(dir, normal);

					console.printf("CWeapLightbringer: [%d] Type [%d] HitPos [%0.2f, %0.2f, %0.2f]", i, tracer.Results.HitType, HitPos.x, HitPos.y, HitPos.z);

					double dist = LemonUtil.v3Distance(nextPos, HitPos);
					distance -= dist;

					double m_angle = self.player.mo.angle;
					double m_pitch = self.player.mo.pitch;
					double m_roll = self.player.mo.roll + weapon.a_roll;

					point = A_GetPoint(indexBeam, i);
					point.Update(HitPos, (m_angle, m_pitch, m_roll));
					point.distance = dist;

					A_SetBounce(indexBeam, i);

					A_BeamBuilder(indexBeam, i, nextPos, false);

					if (tracer.bActor) {
						// damage
						Actor hitActor = tracer.Results.HitActor;
						hitActor.DamageMobj(self, hitActor, damage, "Fire");

						distance = 0;	// we're done with this beam

						Spawn("Pow").SetOrigin(HitPos, false);
					} else {
						nextPos = HitPos + (normal * -1.0);
						damage /= 2.0;

						if (tracer.Results.HitType != TRACE_HitNone) {
							Spawn("Pow").SetOrigin(HitPos, false);
						}
					}
				}
			} else {
				if (weapon.rays[indexBeam].point.size() > i) {
					CWeapLightbringer_Node point = weapon.rays[indexBeam].point[i];
					if (point) {
						point.Update((0,0,0),(0,0,0));
						point.Hide();
					}
				}
			}
		}
    }

	action CWeapLightbringer_Node A_GetPoint(int indexBeam, int segment) {
		CWeapLightbringer weapon = CWeapLightbringer(Player.ReadyWeapon);
		CWeapLightbringer_Node node = null;
		
		int psize = weapon.rays[indexBeam].point.Size();
		if (psize < segment + 1 || psize == 0) {
			// create node
			node = CWeapLightbringer_Node(Spawn("CWeapLightbringer_Node"));
			node.Init("ball");
			weapon.rays[indexBeam].point.Insert(segment, node);
		}
		node = weapon.rays[indexBeam].point[segment];
		return node;
	}

	action CWeapLightbringer_Node A_GetBeam(int indexBeam, int segment, int index, bool isPowered = false) {
		CWeapLightbringer weapon = CWeapLightbringer(Player.ReadyWeapon);
		CWeapLightbringer_Node node = weapon.rays[indexBeam].beams[segment][index];
		if (!node) {
			// create node
			node = CWeapLightbringer_Node(Spawn("CWeapLightbringer_Node"));
			string type = isPowered ? "powered" : "beam";
			node.Init(type);
			weapon.rays[indexBeam].beams[segment].Insert(index, node);
		}
		return node;
	}

	action void A_SetBounce(int indexBeam, int segment) {
		CWeapLightbringer weapon = CWeapLightbringer(Player.ReadyWeapon);
		Actor prev = segment - 1 < 0 ? weapon.beamOrigin : weapon.rays[indexBeam].point[segment - 1];
		CWeapLightbringer_Node next = weapon.rays[indexBeam].point[segment];

		next.A_Face(prev, max_pitch: 0.0, z_ofs: 1.0);
	}

	action void A_BeamBuilder(int indexBeam, int segment, vector3 rootPos, bool isPowered = false) {
		CWeapLightbringer weapon = CWeapLightbringer(Player.ReadyWeapon);
		CWeapLightbringer_Node point = weapon.rays[indexBeam].point[segment];

		double distance = point.distance;

		double spacing = 32.0;
		double dpbeam = distance / spacing;	// (distance per beam) may cause some jank but is fairly faithful to how it displayed in Hexen II
		int iCount = ceil(distance / spacing);

		if (iCount == 0) {
			int segSize = weapon.rays[indexBeam].beams[segment].Size();
			for (double i = 0; i < segSize; i++) {
				CWeapLightbringer_Node beam = A_GetBeam(indexBeam, segment, i, isPowered);
				beam.Remove();
			}
			return;
		}

		int segSize = weapon.rays[indexBeam].beams[segment].Size();
		for (double i = 0; i < segSize; i++) {
			vector3 beamPos = HXDD_GM_VectorUtil.lerpVec3(rootPos, point.pos, i / iCount);
			CWeapLightbringer_Node beam = A_GetBeam(indexBeam, segment, i, isPowered);
			if (dpbeam >= 0.5 && i < iCount) {
				beam.Update(beamPos, (point.angle, point.pitch, point.roll));
			} else {
				beam.Remove();
			}
		}
		if (dpbeam >= 0.5) {
			weapon.rays[indexBeam].beams[segment].Resize(iCount);
		} else {
			weapon.rays[indexBeam].beams[segment].Resize(0);
		}
	}
}

class CWeapLightbringer_Ray {
	Array<CWeapLightbringer_Node> point;
	Array<CWeapLightbringer_Node> beams[3];
}

class CWeapLightbringerTrace: LineTracer {
    bool bFinished;
	bool bActor;
	bool bNone;
	Actor owner;
    override ETraceStatus TraceCallback()  {
		if (Results.HitType == TRACE_HitNone || Results.HitType == TRACE_HitFloor || Results.HitType == TRACE_HitCeiling || Results.HitType == TRACE_HitWall || Results.HitType == TRACE_HitActor) {
			if (Results.HitType == TRACE_HitActor) {
				//if (!Results.HitActor.Player && !Results.HitActor.bMissile && ((Results.HitActor.bIsMonster && !Results.HitActor.bDormant && Results.HitActor.Health > 0) || Results.HitActor.bTouchy)) {
				if (((Results.HitActor.Player && (!Results.HitActor.IsTeammate(self.owner) || level.teamdamage != 0)) || Results.HitActor.bIsMonster) && (!Results.HitActor.bDormant && !Results.HitActor.bInvulnerable)) {
					bActor = true;
					bFinished = true;
					return TRACE_Stop;
				} else {
					return TRACE_Skip;
				}
			}
			if (Results.HitType == TRACE_HitWall) {
				if (Results.Tier == TIER_Middle) {
					if ( Results.HitLine.Flags & Line.ML_TWOSIDED == 0 || Results.HitLine.Flags & Line.ML_BLOCKHITSCAN > 0) {
            			bFinished = true;
               			return TRACE_Stop;
            		} else if (Results.HitLine.Flags & Line.ML_TWOSIDED > 0) {
						return TRACE_Skip; // Pass through two-sided linedefs that don't block hitscans.
					}
            		bFinished = true;
					return TRACE_Stop;
				}
           		bFinished = true;
				return TRACE_Stop; // Don't pass through upper, lower, or 3D floors.
			}
			bNone = (Results.HitType == TRACE_HitNone);
            bFinished = true;
            return TRACE_Stop;
        }
        return TRACE_Skip;
    }

	// https://forum.zdoom.org/viewtopic.php?t=66445&p=1125917#p1125915
	vector3 GetSurfaceNormal() {
		vector3 hitNormal;
		if (!bFinished) {
			console.printf("CWeapLightbringerTrace: Warning, Trace is not finished!");
			return hitNormal;
		}
		if (Results.HitType == TRACE_HitWall) {
			if(!Results.Side) {
				hitNormal = (-Results.Hitline.delta.y, Results.Hitline.delta.x, 0).unit();
			} else {
				hitNormal = (Results.Hitline.delta.y, -Results.Hitline.delta.x, 0).unit();
			}
		} else if (Results.HitType == TRACE_HitFloor) {
			hitNormal = Results.HitSector.FloorPlane.normal;
		} else if (Results.HitType == TRACE_HitCeiling) {
			hitNormal = Results.HitSector.CeilingPlane.normal;
		}
		return hitNormal;
	}
}

class CWeapLightbringer_Node: Actor {
	Actor outer;
	Actor inner;

	double distance;

	int index;

	ParticleGenerator pg;

	Default {
		+NOINTERACTION;
	}

	States {
		Spawn:
			TNT1 A 1;
			Loop;
	}

	void Init(string type = "ball") {
		string outerType = "CWeapLightbringer_Ball";
		string innerType = "CWeapLightbringer_Ball_Inner";
		if (type == "beam") {
			outerType = "CWeapLightbringer_Beam";
			innerType = "CWeapLightbringer_Beam_Inner";
		} else if (type == "powered") {
			outerType = "CWeapLightbringer_Beam_Animated";
			innerType = "CWeapLightbringer_Beam_Inner";
		} else {
			pg = ParticleGenerator(Spawn("ParticleGenerator"));
			pg.Attach(self);
			pg.origin[0] = (-7, -7, -7);
			pg.origin[1] = (7, 7, 7);
			pg.velocity[0] = (0, 0, 10);
			pg.velocity[1] = (0, 0, 15);
			pg.amount = 4;
			pg.lifetime = 1.2;
			pg.rate = 35 * 0.15;
			pg.startalpha = 1.0;
			pg.sizestep = 0.00;
			pg.size = 5;
		}
		self.outer = Spawn(outerType);
		self.inner = Spawn(innerType);

		self.outer.Scale = self.Scale;
		self.inner.Scale = self.Scale;

		self.outer.angle = self.angle;
		self.outer.pitch = self.pitch;
		self.outer.roll = self.roll;
		self.inner.angle = self.angle;
		self.inner.pitch = self.pitch;
		self.inner.roll = self.roll;

		self.SetOrigin((0,0,0), false);
		self.outer.SetOrigin((0,0,0), false);
		self.inner.SetOrigin((0,0,0), false);
	}

	void Update(vector3 nextPos, vector3 nextAngle) {
		if (!self.outer) {
			self.Init();
		}

		bool interpolate = true;
		if (self.pos.x == 0 && self.pos.y == 0 && self.pos.z == 0) {
			interpolate = false;
		}

		self.SetOrigin(nextPos, false);
		self.outer.SetOrigin(nextPos, interpolate);
		self.inner.SetOrigin(nextPos, interpolate);

		self.outer.angle = nextAngle.x;
		self.outer.pitch = nextAngle.y;
		self.outer.roll = nextAngle.z;
		self.inner.angle = nextAngle.x;
		self.inner.pitch = nextAngle.y;
		self.inner.roll = nextAngle.z;
	}

	void Hide() {
		if (self.outer) {
			self.outer.Destroy();
		}
		if (self.inner) {
			self.inner.Destroy();
		}
	}

	void Remove() {
		self.Hide();
		self.Destroy();
	}
}

class CWeapLightbringer_Ball: CWeapLightbringer_FX {
	Default {
		+NOINTERACTION;
		RenderStyle "Add";
		Alpha 0.8;
	}
	
	States {
		Spawn:
			BALL A -1 Bright;
			Loop;
	}
}
class CWeapLightbringer_Ball_Inner: CWeapLightbringer_FX {
	Default {
		+NOINTERACTION;
	}
	
	States {
		Spawn:
			BALL A -1 Bright;
			Loop;
	}
}
class CWeapLightbringer_Beam: CWeapLightbringer_FX {
	Default {
		+NOINTERACTION;
		RenderStyle "Add";
		Alpha 0.8;
	}
	
	States {
		Spawn:
			BEAM A -1 Bright;
			Loop;
	}
}
class CWeapLightbringer_Beam_Animated: CWeapLightbringer_FX {
	Default {
		+NOINTERACTION;
		RenderStyle "Add";
		Alpha 0.8;
	}
	
	States {
		Spawn:
			BEAM ABCDEFG 2 Bright;
			Loop;
	}
}
class CWeapLightbringer_Beam_Inner: CWeapLightbringer_FX {
	Default {
		+NOINTERACTION;
	}
	
	States {
		Spawn:
			BEAM A -1 Bright;
			Loop;
	}
}

// Exists for Tracer Check
class CWeapLightbringer_FX: Actor {
	Default {
		+NOINTERACTION;
		+NOBLOCKMAP;
	}
}