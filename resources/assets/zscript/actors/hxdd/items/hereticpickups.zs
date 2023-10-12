
//
//  Bag of Holding
//
class MultiClassBagOfHolding : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "BagOfHolding";
        self.Corvus = "BagOfHolding";
        self.Fighter = "ArtiBoostMana";
        self.Cleric = "ArtiBoostMana";
        self.Mage = "ArtiBoostMana";
        self.Paladin = "ArtiBoostMana";
        self.Crusader = "ArtiBoostMana";
        self.Necromancer = "ArtiBoostMana";
        self.Assassin = "ArtiBoostMana";
        self.Succubus = "ArtiBoostMana";
    }
}

//
//  Tome Of Power
//
class MultiClassArtiTomeOfPower : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "ArtiTomeOfPower";
        self.Corvus = "ArtiTomeOfPower";
        self.Fighter = "ArtiDarkServant";
        self.Cleric = "ArtiDarkServant";
        self.Mage = "ArtiDarkServant";
        self.Paladin = "ArtiTomeOfPower";
        self.Crusader = "ArtiTomeOfPower";
        self.Necromancer = "ArtiTomeOfPower";
        self.Assassin = "ArtiTomeOfPower";
        self.Succubus = "ArtiTomeOfPower";
    }
}

//
//  Time Bomb
//
class MultiClassArtiTimeBomb : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "ArtiTimeBomb";
        self.Corvus = "ArtiTimeBomb";
        self.Fighter = "ArtiPoisonBag";
        self.Cleric = "ArtiPoisonBag";
        self.Mage = "ArtiPoisonBag";
        self.Paladin = "ArtiPoisonBag";
        self.Crusader = "ArtiPoisonBag";
        self.Necromancer = "ArtiPoisonBag";
        self.Assassin = "ArtiPoisonBag";
        self.Succubus = "ArtiPoisonBag";
    }
}

//
//  Invulnerability
//
class MultiClassArtiInvulnerability : MultiSpawner {
    override void Bind() {
        self.SpawnSelect = "ClassSelect";
        self.Fallback = "ArtiInvulnerability";
        self.Corvus = "ArtiInvulnerability";
        self.Fighter = "ArtiInvulnerability2";
        self.Cleric = "ArtiInvulnerability2";
        self.Mage = "ArtiInvulnerability2";
        self.Paladin = "ArtiInvulnerability2";
        self.Crusader = "ArtiInvulnerability2";
        self.Necromancer = "ArtiInvulnerability2";
        self.Assassin = "ArtiInvulnerability2";
        self.Succubus = "ArtiInvulnerability2";
    }
}  