
class HXDDFighterBoss : FighterBoss replaces FighterBoss
{
	States
	{
	Spawn:
		FIGH A 2;
		FIGH A 3 A_ClassBossHealth;
		FIGH A 5 A_Look;
		Wait;
	See:
		FIGH ABCD 4 A_FastChase;
		Loop;
	Pain:
		FIGH G 4;
		FIGH G 4 A_Pain;
		Goto See;
	Melee:
	Missile:
		FIGH E 8 A_FaceTarget;
		FIGH F 8 A_FighterAttack;
		Goto See;
	Death:
		FIGH H 6;
		FIGH I 6 A_Scream;
		FIGH JK 6;
		FIGH L 6 A_NoBlocking;
		FIGH M 6;
		FIGH N -1;
		Stop;
	XDeath:
		FIGH O 5 A_Scream;
		FIGH P 5 A_SkullPop;
		FIGH R 5 A_NoBlocking;
		FIGH STUV 5;
		FIGH W -1;
		Stop;
	Ice:
		FIGH X 5 A_FreezeDeath;
		FIGH X 1 A_FreezeDeathChunks;
		Wait;
	Burn:
		FDHX A 5 Bright A_StartSound("PlayerFighterBurnDeath");
		FDHX B 4 Bright;
		FDHX G 5 Bright;
		FDHX H 4 Bright A_Scream;
		FDHX I 5 Bright;
		FDHX J 4 Bright;
		FDHX K 5 Bright;
		FDHX L 4 Bright;
		FDHX M 5 Bright;
		FDHX N 4 Bright;
		FDHX O 5 Bright;
		FDHX P 4 Bright;
		FDHX Q 5 Bright;
		FDHX R 4 Bright;
		FDHX S 5 Bright A_NoBlocking;
		FDHX T 4 Bright;
		FDHX U 5 Bright;
		FDHX V 4 Bright;
		Stop;
	}
}
