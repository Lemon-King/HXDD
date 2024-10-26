class HX2SkillNecromancerPlayer: HXDDSkillBase {
	override void OnKill(PlayerPawn player, Actor target, double amount) {
		PlayerSlot pSlot = HXDDPlayerStore.GetPlayerSlot(player.PlayerNumber());

		if (pSlot && pSlot.currlevel >= 5) {
			double chance = 0.05 + (pSlot.currlevel - 3) * 0.03;
			if (chance > 0.2) {
				chance = 0.2;
			}
			if (frandom[poweruporb](0.0, 1.0) > chance) {
				return;
			}
			Actor itemSoulSphere = Spawn("H2SoulSphere");
			itemSoulSphere.SetOrigin(target.pos, false);
			itemSoulSphere.angle = target.angle;
		}
	}
}