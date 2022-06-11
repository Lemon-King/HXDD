
class HXDDClericPlayer : ClericPlayer {
	States
	{
	Spawn:
		CLER A -1;
		Stop;
	See:
		CLER ABCD 4;
		Loop;
	Pain:
		CLER H 4;
		CLER H 4 A_Pain;
		Goto Spawn;
	Missile:
	Melee:
		CLER EFG 6;
		Goto Spawn;
	Death:
		CLER I 6;
		CLER J 6 A_PlayerScream;
		CLER KL 6;
		CLER M 6 A_NoBlocking;
		CLER NOP 6;
		CLER Q -1;
		Stop;
	XDeath:
		CLER R 5 A_PlayerScream;
		CLER S 5;
		CLER T 5 A_NoBlocking;
		CLER UVWXYZ 5;
		CLRF A -1;
		Stop;
	Ice:
		CLRF B 5 A_FreezeDeath;
		CLRF B 1 A_FreezeDeathChunks;
		Wait;
	Burn:
		FDHX C 5 BRIGHT A_StartSound("*burndeath");
		FDHX D 4 BRIGHT;
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