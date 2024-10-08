class HXDDHexenIIPlayerPawn : PlayerPawn {
	// Arrays cannot be passed in a property due to limitations.
	String Weapon1AnimationSetClass;
	int Weapon1AnimationSetIndex;
	String Weapon2AnimationSetClass;
	int Weapon2AnimationSetIndex;
	String Weapon3AnimationSetClass;
	int Weapon3AnimationSetIndex;
	String Weapon4AnimationSetClass;
	int Weapon4AnimationSetIndex;
	int WeaponFallbackAnimationIndex;

	bool HasJumpAnimation;

	property Weapon1AnimationSet: Weapon1AnimationSetIndex, Weapon1AnimationSetClass;
	property Weapon2AnimationSet: Weapon2AnimationSetIndex, Weapon2AnimationSetClass;
	property Weapon3AnimationSet: Weapon3AnimationSetIndex, Weapon3AnimationSetClass;
	property Weapon4AnimationSet: Weapon4AnimationSetIndex, Weapon4AnimationSetClass;
	property WeaponFallbackAnimations: WeaponFallbackAnimationIndex;

	property HasJumpAnimation: HasJumpAnimation;

	Default {
		Health 100;
		PainChance 255;
		Radius 16;
		Height 56;

		//Speed (200.0 / 320.0);
		Speed 1;
		Player.ForwardMove 1, 1;
		Player.SideMove 0.8, 0.8;

		HXDDHexenIIPlayerPawn.HasJumpAnimation true;
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		if (Player) {
			HandlePlayerIdleState();
		}
	}

	//----------------------------------------------------------------------------
	//
	// Hexen II: Unique Weapon Animation States
	//
	//----------------------------------------------------------------------------

	override void PlayIdle() {
		if (!Player) {return;}
		// player.crouching;
		if (!IsInIdleStateSequence() && !IsInFireStateSequence()) {
			if (IsPlayerFlying()) {
				HandlePlayerFlyState();
			} else {
				HandlePlayerIdleState();
			}
		}
	}

	override void PlayRunning() {
		if (!Player) {return;}
		if (!IsInMovementStateSequence() && !IsInFireStateSequence()) {
			if (IsPlayerFlying()) {
				HandlePlayerFlyState();
			} else {
				HandlePlayerRunState();
			}
		}
	}
	
	override void PlayAttacking () {
		if (!Player) {return;}
		if (MissileState != null) {
			if (IsPlayerFlying()) {
				return;
			} else {
				HandlePlayerAttackState(4);
			}
		}
	}

	override void PlayAttacking2 () {
		if (!Player) {return;}
		if (MeleeState != null) {
			if (IsPlayerFlying()) {
				return;
			} else {
				HandlePlayerAttackState(5);
			}
		}
	}

	bool IsPlayerFlying() {
		// TODO
		return false;
	}

	bool IsInIdleStateSequence() {
		State animationStates[6] = {
			Player.mo.FindState("Spawn1"),
			Player.mo.FindState("Spawn2"),
			Player.mo.FindState("Spawn3"),
			Player.mo.FindState("Spawn4"),
			Player.mo.FindState("Spawn"),
			Player.mo.FindState("Crouch")
		};

		for (int i = 0; i < 6; i++) {
			State iState = animationStates[i];
			if (InStateSequence(CurState, iState)) {
				return true;
			}
		}
		return false;
	}
	
	bool IsInMovementStateSequence() {
		State animationStates[12] = {
			Player.mo.FindState("See1"),
			Player.mo.FindState("See2"),
			Player.mo.FindState("See3"),
			Player.mo.FindState("See4"),
			Player.mo.FindState("See"),
			Player.mo.FindState("Fly1"),
			Player.mo.FindState("Fly2"),
			Player.mo.FindState("Fly3"),
			Player.mo.FindState("Fly4"),
			Player.mo.FindState("Fly"),
			Player.mo.FindState("Jump"),
			Player.mo.FindState("Crouch")
		};

		for (int i = 0; i < 11; i++) {
			State iState = animationStates[i];
			if (InStateSequence(CurState, iState)) {
				return true;
			}
		}
		return false;
	}
	
	bool IsInFireStateSequence() {
		State animationStates[6] = {
			Player.mo.FindState("Weapon1"),
			Player.mo.FindState("Weapon2"),
			Player.mo.FindState("Weapon3"),
			Player.mo.FindState("Weapon4"),
			Player.mo.FindState("Missile"),
			Player.mo.FindState("Melee")
		};

		for (int i = 0; i < 6; i++) {
			State iState = animationStates[i];
			if (InStateSequence(CurState, iState)) {
				return true;
			}
		}
		return false;
	}

	void HandlePlayerIdleState(String overrideClassName = "") {
		State animationStates[6] = {
			Player.mo.FindState("Spawn1"),
			Player.mo.FindState("Spawn2"),
			Player.mo.FindState("Spawn3"),
			Player.mo.FindState("Spawn4"),
			Player.mo.FindState("Spawn"),
			Player.mo.FindState("CrouchSpawn")
		};

		int index = 4;
		if (Player.ReadyWeapon != null) {
			String WeaponClass = Player.ReadyWeapon.GetClassName();
			if (overrideClassName != "") {
				WeaponClass = overrideClassName;
			}
			index = GetAnimationSetFromWeaponClass(WeaponClass);
		}
		SetState(animationStates[index]);
	}

	void HandlePlayerRunState(String overrideClassName = "") {
		State animationStates[6] = {
			Player.mo.FindState("See1"),
			Player.mo.FindState("See2"),
			Player.mo.FindState("See3"),
			Player.mo.FindState("See4"),
			Player.mo.FindState("See")
		};

		int index = 4;
		if (Player.ReadyWeapon != null) {
			String WeaponClass = Player.ReadyWeapon.GetClassName();
			if (overrideClassName != "") {
				WeaponClass = overrideClassName;
			}
			index = GetAnimationSetFromWeaponClass(WeaponClass);
		}
		SetState(animationStates[index]);
	}

	void HandlePlayerFlyState(String overrideClassName = "") {
		State animationStates[5] = {
			Player.mo.FindState("Fly1"),
			Player.mo.FindState("Fly2"),
			Player.mo.FindState("Fly3"),
			Player.mo.FindState("Fly4"),
			Player.mo.FindState("Fly")
		};

		int index = 4;
		if (Player.ReadyWeapon != null) {
			String WeaponClass = Player.ReadyWeapon.GetClassName();
			if (overrideClassName != "") {
				WeaponClass = overrideClassName;
			}
			index = GetAnimationSetFromWeaponClass(WeaponClass);
		}
		SetState(animationStates[index]);
	}

	void HandlePlayerAttackState(int defaultIndex = 0) {
		State animationStates[6] = {
			Player.mo.FindState("Weapon1"),
			Player.mo.FindState("Weapon2"),
			Player.mo.FindState("Weapon3"),
			Player.mo.FindState("Weapon4"),
			Player.mo.FindState("Missile"),
			Player.mo.FindState("Melee")
		};

		int index = defaultIndex;
		if (Player.ReadyWeapon != null) {
			String WeaponClass = Player.ReadyWeapon.GetClassName();
			index = GetAnimationSetFromWeaponClass(WeaponClass);
		}
		SetState(animationStates[index]);
	}

	String lastWeaponClass;
	override void CheckWeaponChange() {
		Super.CheckWeaponChange();

		let player = self.player;
		if (!player) return;
		if (player.PendingWeapon != WP_NOCHANGE) {
			String WeaponClass = Player.PendingWeapon.GetClassName();
			if (lastWeaponClass != WeaponClass) {
				lastWeaponClass = WeaponClass;
				if (IsInIdleStateSequence()) {
					if (IsPlayerFlying()) {
						HandlePlayerFlyState(WeaponClass);
					} else {
						HandlePlayerIdleState(WeaponClass);
					}
				} else if (IsInMovementStateSequence()) {
					if (IsPlayerFlying()) {
						HandlePlayerFlyState(WeaponClass);
					} else {
						HandlePlayerRunState(WeaponClass);
					}
				}
			}
		}
	}

	int GetAnimationSetFromWeaponClass(string WeaponClass) {
		if (Weapon1AnimationSetClass == WeaponClass) {
			return Weapon1AnimationSetIndex - 1;
		} else if (Weapon2AnimationSetClass == WeaponClass) {
			return Weapon2AnimationSetIndex - 1;
		} else if (Weapon3AnimationSetClass == WeaponClass) {
			return Weapon3AnimationSetIndex - 1;
		} else if (Weapon4AnimationSetClass == WeaponClass) {
			return Weapon4AnimationSetIndex - 1;
		} else {
			return WeaponFallbackAnimationIndex - 1;
		}
	}

	bool isOnGround;
	override void CheckJump() {
		Super.CheckJump();
		if (!HasJumpAnimation) {
			return;
		}
		let player = self.player;
		if (player.cmd.buttons & BT_JUMP) {
			// Jumping
			if (player.jumpTics != 0) {
				State stJump = Player.mo.FindState("Jump");
				if (!InStateSequence(CurState, stJump) && !IsInFireStateSequence()) {
					SetState(stJump);
				}
				isOnGround = false;
			}
		} else if (Vel.Z < -6.001 && player.jumpTics == 0) {	// should prevent stair jank while walking
			// Falling
			State stJump = Player.mo.FindState("Jump");
			if (!InStateSequence(CurState, stJump)) {
				SetState(stJump);
			}
			isOnGround = false;
		} else if (!isOnGround && player.onground) {
			// Landing
			isOnGround = true;
			HandlePlayerIdleState();
		}
	}

	override void CheckCrouch(bool totallyfrozen) {
		Super.CheckCrouch(totallyfrozen);

		// TODO: use player.zs -> checkcrouch implementation
	}


	void A_SkullPop(class<PlayerChunk> skulltype = "BloodySkull")
	{
		// [GRB] Parameterized version
		if (skulltype == NULL || !(skulltype is "PlayerChunk"))
		{
			skulltype = "BloodySkull";
			if (skulltype == NULL)
				return;
		}

		bSolid = false;
		let mo = PlayerPawn(Spawn (skulltype,  Pos + (0, 0, 48), NO_REPLACE));
		//mo.target = self;
		mo.Vel.X = Random2[SkullPop]() / 128.;
		mo.Vel.Y = Random2[SkullPop]() / 128.;
		mo.Vel.Z = 5 + (Random[SkullPop]() / 1024.);
		// Attach player mobj to bloody skull
		let player = self.player;
		self.player = NULL;
		mo.ObtainInventory (self);
		mo.player = player;
		mo.health = health;
		mo.Angle = Angle;
		if (player != NULL)
		{
			player.mo = mo;
			player.damagecount = 32;
		}
		for (int i = 0; i < MAXPLAYERS; ++i)
		{
			if (playeringame[i] && players[i].camera == self)
			{
				players[i].camera = mo;
			}
		}
	}
}