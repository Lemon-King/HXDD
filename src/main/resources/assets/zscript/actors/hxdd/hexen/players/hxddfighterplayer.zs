// The fighter --------------------------------------------------------------
// Modifcations to sprite names for HHDD, might break?

class HXDDFighterPlayer : FighterPlayer
{
	States
	{
	Spawn:
		FIGH A -1;
		Stop;
	See:
		FIGH ABCD 4;
		Loop;
	Missile:
	Melee:
		FIGH EF 8;
		Goto Spawn;
	Pain:
		FIGH G 4;
		FIGH G 4 A_Pain;
		Goto Spawn;
	Death:
		FIGH H 6;
		FIGH I 6 A_PlayerScream;
		FIGH JK 6;
		FIGH L 6 A_NoBlocking;
		FIGH M 6;
		FIGH N -1;
		Stop;		
	XDeath:
		FIGH O 5 A_PlayerScream;
		FIGH P 5 A_SkullPop("BloodyFighterSkull");
		FIGH R 5 A_NoBlocking;
		FIGH STUV 5;
		FIGH W -1;
		Stop;
	Ice:
		FIGH X 5 A_FreezeDeath;
		FIGH X 1 A_FreezeDeathChunks;
		Wait;
	Burn:
		FDHX A 5 BRIGHT A_StartSound("*burndeath");
		FDHX B 4 BRIGHT;
		FDHX G 5 BRIGHT;
		FDHX H 4 BRIGHT A_PlayerScream;
		FDHX I 5 BRIGHT;
		FDHX J 4 BRIGHT;
		FDHX K 5 BRIGHT;
		FDHX L 4 BRIGHT;
		FDHX M 5 BRIGHT;
		FDHX N 4 BRIGHT;
		FDHX O 5 BRIGHT;
		FDHX P 4 BRIGHT;
		FDHX Q 5 BRIGHT;
		FDHX R 4 BRIGHT;
		FDHX S 5 BRIGHT A_NoBlocking;
		FDHX T 4 BRIGHT;
		FDHX U 5 BRIGHT;
		FDHX V 4 BRIGHT;
		ACLO E 35 A_CheckPlayerDone;
		Wait;
		ACLO E 8;
		Stop;
	}
}
