
class HXDDMageBoss : MageBoss replaces MageBoss
{
	States
	{
	Spawn:
		MAGE A 2;
		MAGE A 3 A_ClassBossHealth;
		MAGE A 5 A_Look;
		Wait;
	See:
		MAGE ABCD 4 A_FastChase;
		Loop;
	Pain:
		MAGE G 4;
		MAGE G 4 A_Pain;
		Goto See;
	Melee:
	Missile:
		MAGE E 8 A_FaceTarget;
		MAGE F 8 Bright A_MageAttack;
		Goto See;
	Death:
		MAGE H 6;
		MAGE I 6 A_Scream;
		MAGE JK 6;
		MAGE L 6 A_NoBlocking;
		MAGE M 6;
		MAGE N -1;
		Stop;
	XDeath:
		MAGE O 5 A_Scream;
		MAGE P 5;
		MAGE R 5 A_NoBlocking;
		MAGE S 5;
		MAGE T 5;
		MAGE U 5;
		MAGE V 5;
		MAGE W 5;
		MAGE X -1;
		Stop;
	Ice:
		MAGE Y 5 A_FreezeDeath;
		MAGE Y 1 A_FreezeDeathChunks;
		Wait;
	Burn:
		FDHX E 5 Bright A_StartSound("PlayerMageBurnDeath");
		FDHX F 4 Bright;
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