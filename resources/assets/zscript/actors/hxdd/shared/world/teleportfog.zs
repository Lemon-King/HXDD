
class DOOMTeleportFog : Actor
{
	default
	{
		+NOBLOCKMAP
		+NOTELEPORT
		+NOGRAVITY
		+ZDOOMTRANS
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		TFOG ABABCDEFGHIJ 6 Bright;
		Stop;
	}

	override void PostBeginPlay ()
	{
		Super.PostBeginPlay ();

		A_StartSound ("doom/misc/teleport", CHAN_BODY);
	}
}

class HereticTeleportFog : Actor
{
	default
	{
		+NOBLOCKMAP
		+NOTELEPORT
		+NOGRAVITY
		+ZDOOMTRANS
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		TELE ABCDEFGHGFEDC 6 Bright;
		Stop;
	}

	override void PostBeginPlay ()
	{
		Super.PostBeginPlay ();

		A_StartSound ("heretic/misc/teleport", CHAN_BODY);
	}
}

class HXTeleportFog : Actor
{
	default
	{
		+NOBLOCKMAP
		+NOTELEPORT
		+NOGRAVITY
		+ZDOOMTRANS
		RenderStyle "Add";
	}
	States
	{
	Spawn:
	TELE ABCDEFGHGFEDC 6 Bright;
		Stop;
	}

	override void PostBeginPlay ()
	{
		Super.PostBeginPlay ();

		A_StartSound ("hexen/misc/teleport", CHAN_BODY);
	}
}

class HX2TeleportFog : Actor
{
	default
	{
		+NOBLOCKMAP
		+NOTELEPORT
		+NOGRAVITY
		+ZDOOMTRANS
		RenderStyle "Add";
	}
	States
	{
	Spawn:
		TELE ABCDEFGHGFEDC 6 Bright;
		Stop;
	}

	override void PostBeginPlay ()
	{
		Super.PostBeginPlay ();

		A_StartSound (String.format("hexen2/misc/teleprt%d", random(1,5)), CHAN_BODY);
	}
}