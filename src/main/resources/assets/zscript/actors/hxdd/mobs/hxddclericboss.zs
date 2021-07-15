
class HXDDClericBoss : ClericBoss replaces ClericBoss
{
	States
	{
	Spawn:
		CLER A 2;
		CLER A 3 A_ClassBossHealth;
		CLER A 5 A_Look;
		Wait;
	See:
		CLER ABCD 4 A_FastChase;
		Loop;
	Pain:
		CLER H 4;
		CLER H 4 A_Pain;
		Goto See;
	Melee:
	Missile:
		CLER EF 8 A_FaceTarget;
		CLER G 10 A_ClericAttack;
		Goto See;
	Death:
		CLER I 6;
		CLER K 6 A_Scream;
		CLER LL 6;
		CLER M 6 A_NoBlocking;
		CLER NOP 6;
		CLER Q -1;
		Stop;
	XDeath:
		CLER R 5 A_Scream;
		CLER S 5;
		CLER T 5 A_NoBlocking;
		CLER UVWXYZ 5;
		CLER [ -1;
		Stop;
	Ice:
		CLRF B 5 A_FreezeDeath;
		CLRF B 1 A_FreezeDeathChunks;
		Wait;
	Burn:
		CLER C 5 Bright A_StartSound("PlayerClericBurnDeath");
		FDHX D 4 Bright ;
		FDHX G 5 Bright ;
		FDHX H 4 Bright A_Scream;
		FDHX I 5 Bright ;
		FDHX J 4 Bright ;
		FDHX K 5 Bright ;
		FDHX L 4 Bright ;
		FDHX M 5 Bright ;
		FDHX N 4 Bright ;
		FDHX O 5 Bright ;
		FDHX P 4 Bright ;
		FDHX Q 5 Bright ;
		FDHX R 4 Bright ;
		FDHX S 5 Bright A_NoBlocking;
		FDHX T 4 Bright ;
		FDHX U 5 Bright ;
		FDHX V 4 Bright ;
		Stop;
	}
}