
class HXDDTeleportFog : Actor {
	default
	{
		+NOBLOCKMAP
		+NOTELEPORT
		+NOGRAVITY
		+ZDOOMTRANS
		-MISSILE
		RenderStyle "Add";
	}

	void CorrectSpawnOffset(int height) {
		int offset = max(0, self.pos.z - self.floorz);
		self.SetOrigin(self.pos + (0, 0, 32 - offset), true);
	}
}

class DOOMTeleportFog : HXDDTeleportFog
{
	States
	{
	Spawn:
		TFOG ABABCDEFGHIJ 6 Bright;
		Stop;
	}
	
	override void PostBeginPlay ()
	{
		Super.PostBeginPlay ();

		CorrectSpawnOffset(32);
		A_StartSound ("doom/misc/teleport", CHAN_BODY);
	}
}

class HereticTeleportFog : HXDDTeleportFog
{
	States
	{
	Spawn:
		TELE ABCDEFGHGFEDC 6 Bright;
		Stop;
	}
	
	override void PostBeginPlay ()
	{
		Super.PostBeginPlay ();

		CorrectSpawnOffset(32);
		A_StartSound ("heretic/misc/teleport", CHAN_BODY);
	}
}

class HXTeleportFog : HXDDTeleportFog
{
	States
	{
	Spawn:
		TELE ABCDEFGHGFEDC 6 Bright;
		Stop;
	}
	
	override void PostBeginPlay ()
	{
		Super.PostBeginPlay ();

		CorrectSpawnOffset(32);
		A_StartSound ("hexen/misc/teleport", CHAN_BODY);
	}
}

class HX2TeleportFog : HXDDTeleportFog
{
	States
	{
	Spawn:
		TELE ABCDEFGHGFEDC 6 Bright;
		Stop;
	}
	
	override void PostBeginPlay ()
	{
		Super.PostBeginPlay ();

		CorrectSpawnOffset(32);	// PH
		A_StartSound (String.format("hexen2/misc/teleprt%d", random(1,5)), CHAN_BODY);
	}
}