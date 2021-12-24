
class PaladinWeapon : Hexen2Weapon
{
	Default
	{
		Weapon.Kickback 150;
		Inventory.RestrictedTo "PaladinPlayer";
	}
}

class CrusaderWeapon : Hexen2Weapon
{
	Default
	{
		Weapon.Kickback 150;
		Inventory.RestrictedTo "CrusaderPlayer";
	}
}

class NecromancerWeapon : Hexen2Weapon
{
	Default
	{
		Weapon.Kickback 150;
		Inventory.RestrictedTo "NecromancerPlayer";
	}
}

class AssassinWeapon : Hexen2Weapon
{
	Default
	{
		Weapon.Kickback 150;
		Inventory.RestrictedTo "AssassinPlayer";
	}
}

class SuccubusWeapon : Hexen2Weapon
{
	Default
	{
		Weapon.Kickback 150;
		Inventory.RestrictedTo "SuccubusPlayer";
	}
}

class Hexen2Projectile: Actor {
    double veerAmount;
	property veerAmount: veerAmount;

    int nextHomeUpdate;
    double homeRate;
    Actor lockEntity;
    Actor oldLockEntity;
    Vector3 huntDir;
    double turnTime;
    bool hoverz;
	property homeRate: homeRate;
	property turnTime: turnTime;
	property hoverz: hoverz;

    override void BeginPlay() {
        Super.BeginPlay();

        lockEntity = self;
        oldLockEntity = self;
    }

    override void Tick() {
        Super.Tick();
		if (InStateSequence(CurState, self.Findstate("Death"))) {
			return;
		}
        if (!Homing()) {
            Veer();
        }
    }

    void Veer() {
        if (veerAmount > 0) {
            vel += RandomVector((veerAmount / 32.0f, veerAmount / 32.0f, veerAmount / 32.0f));
            Vector3 newAngle = vectoangles(vel);

            angle = newAngle.x;
            pitch = newAngle.y;
            roll = newAngle.z;

            //self.A_ChangeVelocity(newVelocity.x, newVelocity.y, newVelocity.z);
        }
    }

    //ref: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/HCode/math.hc#L71
    Vector3 RandomVector(Vector3 vrange) {
        Vector3 newVec;
        newVec.x = frandom(vrange.x,0.0f-vrange.x);
        newVec.y = frandom(vrange.y,0.0f-vrange.y);
        newVec.z = frandom(vrange.z,0.0f-vrange.z);
        return newVec;
    }

    //ref: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/Client/cl_cam.c#L35
    Vector3 vectoangles(Vector3 vec) {
        double forward;
        double yaw;
        double pitch;
        
        if (vec.y == 0 && vec.x == 0) {
            yaw = 0.0f;
            if (vec.z > 0)
                pitch = 90.0f;
            else
                pitch = 270.0f;
        } else {
            yaw = (atan2(vec.y, vec.x) * 180 / M_PI);
            if (yaw < 0)
                yaw += 360;

            forward = sqrt(vec.x*vec.x + vec.y*vec.y);
            pitch = (atan2(vec.z, forward) * 180 / M_PI);
            if (pitch < 0)
                pitch += 360;
        }

        return (pitch, yaw, 0);
    }

    // Homing, not be functioning correctly
    // ref: https://github.com/videogamepreservation/hexen2/blob/eac5fd50832ce2509226761b3b1a387c468e7a50/H2W/HCode/projbhvr.hc#L335
    bool Homing() {
        if (homeRate == 0) {
            // Try veer
            return false;
        }
        if ((nextHomeUpdate++ % 2) != 0) {
            return false;
        }

        bool entityIsVisible = IsVisible(lockEntity, true);
        if (!entityIsVisible) {
            oldLockEntity = lockEntity;
            lockEntity = self;
        }
        if (lockEntity == self || !lockEntity) {
            if (random[homing](0.0, 1.0) < 0.3) {
                Actor nextEntity = GetEntitiesInRange(100.0);
                if (nextEntity) {
                    oldLockEntity = lockEntity;
                    lockEntity = nextEntity;
                    console.printf("New Target: %s", lockEntity.GetClassName());
                }
            }
        }
        if (lockEntity == self || !lockEntity) {
            return false;
        }
        if (entityIsVisible) {
            // do homing
            Vector3 newDir = (0,0,0);
            Vector3 oldDir = normalize(vel);

            double oldVelMult;
            double newVelDiv;
            double speed_mod;

            huntDir = normalize(lockEntity.pos - self.pos);
            oldVelMult = turnTime;
            newVelDiv = 1.0 / (turnTime + 1.0);
		    newDir = (oldDir * oldVelMult + huntDir) * newVelDiv;
            if (hoverz) {
                speed_mod = oldDir dot newDir;
            } else {
                speed_mod = 1.0;
            }
            if (speed_mod < 0.05) {
                speed_mod = 0.05;
            }
            if (vel != huntDir * speed) {
                vel += (olddir * oldvelmult + huntdir) * newveldiv * speed * speed_mod;
            }
        }
        Veer();

        return true;
    }

    // Can't exactly use CheckProximity
    Actor GetEntitiesInRange(double radius) {
        BlockThingsIterator it = BlockThingsIterator.Create(self, radius);
        Actor target = NULL;
        double dist = 999999999;

        while (it.Next()) {
            Actor mo = it.thing;
            double dist3d = Distance3D(mo);
            //console.printf("Target %s, Range: 0.2f", mo.GetClassName(), dist3d);
            if (mo && mo.bSolid && dist3d < radius && mo.CountsAsKill() && mo.health > 0 && !(mo is "PlayerPawn")) {
                if (dist > dist3d) {
                    target = mo;
                    dist = dist3d;
                }
            }
        }
        return target;
    }
    
    Vector3 normalize(Vector3 vec) {
        double w = sqrt(vec.x * vec.x + vec.y * vec.y + vec.z * vec.z);
        if (w == 0) {
            return (0,0,0);
        }
        return (vec.x / w, vec.y / w, vec.z / w);
    }
}

class Hexen2Weapon: Weapon {
	const WEAPON1_BASE_DAMAGE			= 12;
	const WEAPON1_ADD_DAMAGE			= 12;
	const WEAPON1_PWR_BASE_DAMAGE		= 30;
	const WEAPON1_PWR_ADD_DAMAGE		= 20;
	const WEAPON1_PUSH					= 5;
	const MELEE_RANGE					= DEFMELEERANGE * 1.5;

	
	Default {
	}

	// https://discord.com/channels/268086704961748992/268877450652549131/918244841031364618
	// https://pastebin.com/uKz6EgKE
    action Actor SpawnFirstPerson(class<Actor> proj, double forward = 0, double leftright = 0, double updown = 0, bool crosshairConverge = true, double angleoffs = 0, double pitchoffs = 0) {
        double a = angle + angleoffs;
        double p = Clamp(pitch + pitchoffs, -90, 90);
        double r = roll;
        let mat = HXDD_GM_Matrix.fromEulerAngles(a, p, r);
        mat = mat.multiplyVector3((forward, -leftright, updown));
        vector3 offsetPos = mat.asVector3(false);
        
        vector3 shooterPos = (pos.xy, pos.z + height * 0.5);
        if(player) shooterPos.z = player.viewz;
        offsetPos = level.vec3offset(offsetPos, shooterPos);
        
        // Get velocity
        vector3 aimpos;
        if(player && crosshairConverge) {
            FLineTraceData lt;
            LineTrace(a, 1024*1024, p, 0, player.viewz-pos.z, 0, data:lt);
            aimPos = lt.HitLocation;
            //Spawn("PK_DebugSpot", aimPos);
        
            vector3 aimAngles = level.SphericalCoords(offsetPos, aimPos, (a, p));
            
            a -= aimAngles.x;
            p -= aimAngles.y;
        }
        
        mat = HXDD_GM_Matrix.fromEulerAngles(a, p, r);
        mat = mat.multiplyVector3((1.0,0,0));
        
        vector3 projVel = mat.asVector3(false) * GetDefaultByType(proj).Speed;
        
        // Spawn projectile
        let proj = Spawn(proj, offsetPos);
        if(proj)
        {
            proj.angle = a;
            proj.pitch = p;
            proj.roll = r;
            proj.vel = projVel;
            proj.target = self;
            if (proj.seesound)
                proj.A_StartSound(proj.seesound);
        }
        return proj;
    }
}
