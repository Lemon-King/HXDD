
// TODO: Add CVAR to cap level at 10 or disable and normalize player performance
// TODO: Break out Progression System into an Inventory Item Handler
// TODO: Break out Armor Selection into an Inventory Item Handler
// TODO: Break out Compatability Scale into an Inventory Item Handler
		
class HXDDPlayerPawn : PlayerPawn
{
	// Hexen 2 values
	// Ref: https://github.com/sezero/uhexen2/blob/5da9351b3a219629ffd1b287d8fa7fa206e7d136/gamecode/hc/portals/stats.hc

	String DefaultArmorMode;
	String DefaultProgression;

	// Class Tables
	double experienceTable[11];
	double hitpointTable[5];
	double manaTable[5];
	double strengthTable[2];
	double intelligenceTable[2];
	double wisdomTable[2];
	double dexterityTable[2];

	// Character Stats
	int level;
	int experience;
	double experienceModifier;

	//int maxHealth; // Use Player.MaxHealth
	int maxMana;
	int strength;
	int intelligence;
	int wisdom;
	int dexterity;

	// Gameplay Modes
	property DefaultArmorMode: DefaultArmorMode;
	property DefaultProgression: DefaultProgression;

	// Class Tables
	property experienceTable: experienceTable;
	property hitpointTable: hitpointTable;
	property manaTable: manaTable;
	property strengthTable: strengthTable;
	property intelligenceTable: intelligenceTable;
	property wisdomTable: wisdomTable;
	property dexterityTable: dexterityTable;

	// Character Stats
	property Level: level;
	property Experience: experience;
	property ExperienceModifier: experienceModifier;

	//property MaxHealth; // Use Player.MaxHealth
	property MaxMana: maxMana;
	property Strength: strength;
	property Intelligence: intelligence;
	property Wisdom: wisdom;
	property Dexterity: dexterity;

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

	property Weapon1AnimationSet: Weapon1AnimationSetClass, Weapon1AnimationSetIndex;
	property Weapon2AnimationSet: Weapon2AnimationSetClass, Weapon2AnimationSetIndex;
	property Weapon3AnimationSet: Weapon3AnimationSetClass, Weapon3AnimationSetIndex;
	property Weapon4AnimationSet: Weapon4AnimationSetClass, Weapon4AnimationSetIndex;
	property WeaponFallbackAnimations: WeaponFallbackAnimationIndex;

	property HasJumpAnimation: HasJumpAnimation;

	Default
	{
		HXDDPlayerPawn.ExperienceModifier 1.0;
		HXDDPlayerPawn.DefaultArmorMode "classic";
		HXDDPlayerPawn.DefaultProgression "classic";
		HXDDPlayerPawn.Level 0;
		HXDDPlayerPawn.Experience 0;
		
		HXDDPlayerPawn.MaxMana 0;
		HXDDPlayerPawn.Strength 0;
		HXDDPlayerPawn.Intelligence 0;
		HXDDPlayerPawn.Wisdom 0;
		HXDDPlayerPawn.Dexterity 0;

		HXDDPlayerPawn.HasJumpAnimation true;
	}

	override void BeginPlay() {
		Super.BeginPlay();
		if (experienceTable[0] == 0) {
			SetAdvancementStatTables();
		}
	}

	override void PostBeginPlay() {
		Super.PostBeginPlay();

		HandlePlayerIdleState();
	}

	//----------------------------------------------------------------------------
	//
	// Hexen II: Unique Weapon Animation States
	//
	//----------------------------------------------------------------------------

	override void PlayIdle() {
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
		if (!IsInMovementStateSequence() && !IsInFireStateSequence()) {
			if (IsPlayerFlying()) {
				HandlePlayerFlyState();
			} else {
				HandlePlayerRunState();
			}
		}
	}
	
	override void PlayAttacking () {
		if (MissileState != null) {
			if (IsPlayerFlying()) {
				return;
			} else {
				HandlePlayerAttackState(4);
			}
		}
	}

	override void PlayAttacking2 () {
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
			Player.mo.FindState("Jump")
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
		State animationStates[11] = {
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
			Player.mo.FindState("Jump")
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
			Player.mo.FindState("See"),
			Player.mo.FindState("Crouch")
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

	virtual void SetAdvancementStatTables() {}
	virtual void OnExperienceBonus(double experience) {}
	virtual void OnKill(Actor target, double experience) {}
}