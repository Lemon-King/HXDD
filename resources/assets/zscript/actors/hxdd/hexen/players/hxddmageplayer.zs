class HXDDMagePlayer : MagePlayer
{
	States
	{
	Spawn:
		MAGE A -1;
		Stop;
	See:
		MAGE ABCD 4;
		Loop;
	Missile:
	Melee:
		MAGE EF 8;
		Goto Spawn;
	Pain:
		MAGE G 4;
		MAGE G 4 A_Pain;
		Goto Spawn;
	Death:
		MAGE H 6;
		MAGE I 6 A_PlayerScream;
		MAGE JK 6;
		MAGE L 6 A_NoBlocking;
		MAGE M 6;
		MAGE N -1;
		Stop;
	XDeath:
		MAGE O 5 A_PlayerScream;
		MAGE P 5;
		MAGE R 5 A_NoBlocking;
		MAGE STUVW 5;
		MAGE X -1;
		Stop;
	Ice:
		MAGE Y 5 A_FreezeDeath;
		MAGE Y 1 A_FreezeDeathChunks;
		Wait;
	Burn:
		FDHX E 5 BRIGHT A_StartSound("*burndeath");
		FDHX F 4 BRIGHT;
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