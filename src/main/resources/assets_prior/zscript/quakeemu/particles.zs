
/*
** Simple Quake Engine like Particle FX Generator
** With support for Actor Particles
**
** "If particles used real sprites instead of blocks, they could be much
** more useful." - Randy Heit
** https://github.com/coelckers/gzdoom/blob/4bcea0ab783c667940008a5cab6910b7a826f08c/src/playsim/p_effect.cpp#L33
*/

// TODO: Insert open source license thats seperate from the main mod
// Allowing users to use this file in their projects as they choose
// as long as they include this license and give credit to the author

class ParticleGenerator: Actor {
    Array<String> actorParticleTypes;

    int amount;
    int rate;
    int ticks;
    int tickDuration;

    double lifetime;
    double size;
    vector3 color[2];
    vector3 origin[2];
    vector3 velocity[2];
    vector3 accel[2];
    double startalpha;
    double fadestep;
    double sizestep;

    bool flag_fullBright;
    bool flag_relative;
    bool flag_relpos;
    bool flag_relvel;
    bool flag_relaccel;
    bool flag_relang;
    bool flag_notimefreeze;

    Default {
		Height 0;
		+NOBLOCKMAP
		+NOGRAVITY
		+INVISIBLE
    }

    override void BeginPlay() {
        Super.BeginPlay();

        rate = 1;
        amount = 3;
        size = 3.0;
        lifetime = 2.0;
        startalpha = 1.0;
        fadestep = -1;
    }

    override void PostBeginPlay() {
        Super.PostBeginPlay();

        RefreshOrigin(false);
    }

    override void Tick() {
        Super.Tick();

        if ((!self.target && self.tickDuration == 0) || (self.tickDuration != 0 && self.ticks > self.tickDuration)) {
            self.Remove();
            return;
        }

        RefreshOrigin();

        // https://zdoom.org/wiki/A_SpawnParticle
        if (self.ticks++ % self.rate == 0) {
            int flags = 0;
            if (flag_fullBright) {
                flags |= SPF_FULLBRIGHT;
            }
            if (flag_relative) {
                flags |= SPF_RELATIVE;
            } else {
                if (flag_relpos) {
                    flags |= SPF_RELPOS;
                }
                if (flag_relvel) {
                    flags |= SPF_RELVEL;
                }
                if (flag_relaccel) {
                    flags |= SPF_RELACCEL;
                }
                if (flag_relang) {
                    flags |= SPF_RELANG;
                }
            }
            if (flag_notimefreeze) {
                flags |= SPF_NOTIMEFREEZE;
            }
            for (int i = 0; i < amount; i++) {
                double ticksLifetime = CustomLifetime(i) * (1000.0 / 35);
                double c_size = CustomSize(i);
                double c_angle = CustomAngle(i);

                // Colors should be sourced from palette.lmp
                vector3 rgb = self.CustomColor(i);
                int red = rgb.x;
                int green = rgb.y;
                int blue = rgb.z;
                int color = (red << 16) | (green << 8) | (blue);

                vector3 c_origin = CustomOrigin(i);
                vector3 c_velocity = CustomVelocity(i);
                vector3 c_accel = CustomAcceleration(i);

                double c_startalpha = CustomStartAlpha(i);
                double c_fadestep = CustomFadeStep(i);
                double c_sizestep = CustomSizeStep(i);

                int totalActorParticleTypes = self.actorParticleTypes.size();
                if (totalActorParticleTypes > 0) {
                    String tActor = CustomActorType(i);
                    ActorParticle p = ActorParticle(Spawn(tActor));
                    if (p) {
                        p.c_lifetime = ticksLifetime;
                        p.c_size = c_size;
                        p.c_color = rgb;
                        p.c_origin = self.pos + c_origin;
                        p.c_velocity = c_velocity;
                        p.c_accel = c_accel;
                        p.c_startalpha = c_startalpha;
                        p.c_fadestep = c_fadestep;
                        p.c_sizestep = sizestep;
                    }
                } else {
                    self.A_SpawnParticle(color, flags, ticksLifetime, c_size, c_angle, c_origin.x, c_origin.y, c_origin.z, c_velocity.x, c_velocity.y, c_velocity.z, c_accel.x, c_accel.y, c_accel.z, c_startalpha, c_fadestep, c_sizestep);
                }
            }
        }

        PostTick();
    }

    void Attach(Actor parent) {
        self.target = parent;
    }

    void Remove() {
        self.Destroy();
    }

    // Programmatic overrides for more finely controlled particle effects
    // Defaults use predefined and randomly defined ranges
    virtual String CustomActorType(int index) {
        int totalActorParticleTypes = self.actorParticleTypes.size();
        return self.actorParticleTypes[random(0, totalActorParticleTypes - 1)];
    }
    virtual double CustomLifetime(int index) {
        return lifetime;
    }
    virtual double CustomSize(int index) {
        return size;
    }
    virtual double CustomAngle(int index) {
        if (self.target) {
            return self.target.angle;
        }
        return 0.0;
    }
    virtual vector3 CustomColor(int index) {
        return v3Lerp(color[0], color[1], frandom(0.0, 1.0));
    }
    virtual vector3 CustomOrigin(int index) {
        return GetRandVector3(self.origin[0], self.origin[1]);
    }
    virtual vector3 CustomVelocity(int index) {
        // Quake style Velocity is divied by 32 to match GZDoom's velocity
        return GetRandVector3(self.velocity[0], self.velocity[1]) * 0.03125;
    }
    virtual vector3 CustomAcceleration(int index) {
        // Quake style Acceleration is divied by 32 to match GZDoom's acceleration
        return GetRandVector3(self.accel[0], self.accel[1]) * 0.03125;
    }
    virtual double CustomStartAlpha(int index) {
        return startalpha;
    }
    virtual double CustomFadeStep(int index) {
        return fadestep;
    }
    virtual double CustomSizeStep(int index) {
        return sizestep;
    }
    virtual void PostTick() {
        // An empty call by default, but can be used for post tick checks
    }

    void SetSpawnOrigin(vector3 o) {
        if (!self.target) {
            self.SetOrigin(o, false);
        }
    }

    void RefreshOrigin(bool interpolate = true) {
        if (!self.target) {
            return;
        }
        self.angle = self.target.angle;
        self.pitch = self.target.pitch;
        self.roll = self.target.roll;
        self.SetOrigin(self.target.pos, interpolate);
    }

    vector3 GetRandVector3(vector3 vecLow, vector3 vecHigh) {
        return (frandom(vecLow.x, vecHigh.x), frandom(vecLow.y, vecHigh.y), frandom(vecLow.z, vecHigh.z));
    }

    vector3 v3Lerp(vector3 a, vector3 b, float f) {
        return (a * (1.0 - f)) + (b * f);
    }
}

// A needlessly complex particle that can look pretty and do neat things
// Such as interacting with the world and causing chaos
// HW Renderer: https://github.com/coelckers/gzdoom/blob/1c3e0f1a755677f480b21ee1cd8c2c80343f9202/src/rendering/hwrenderer/scene/hw_sprites.cpp#L1202
class ActorParticle: Actor {
    double c_lifetime;
    double c_size;
    vector3 c_color;
    vector3 c_origin;
    vector3 c_velocity;
    vector3 c_accel;
    double c_startalpha;
    double c_fadestep;
    double c_sizestep;

	Default {
        +NOGRAVITY;

        RenderStyle "Translucent";

		Speed 0;
		Radius 1;
		Height 1;
        Scale 1;  // 1 / sprite size
        Alpha 1;
	}
	States {
        Spawn:
            PART A 1;
            Loop;
	}

    override void PostBeginPlay() {
        Super.PostBeginPlay();

        double glFactor = 1.0/7.0;

        self.Scale.x *= glFactor;
        self.Scale.y *= glFactor;
        self.Scale.x *= self.c_size;
        self.Scale.y *= self.c_size;
        self.A_SetSize(self.Scale.x, self.Scale.y);

        self.SetOrigin(self.c_origin, false);

        if (self.c_fadestep < 0 && self.c_lifetime > 0) {
            self.c_fadestep = FadeFromLifetime(self.c_lifetime);
        }
    }

    override void Tick() {
        Super.Tick();

        double glFactor = 1.0/7.0;

		self.Alpha -= self.c_fadestep;
		self.Scale.x += self.c_sizestep * glFactor;
		self.Scale.y += self.c_sizestep * glFactor;
        A_SetSize(self.Scale.x, self.Scale.y);

        /*
		double floorz;
		sector floorsec;
        [floorz, floorsec] = self.curSector.LowestFloorAt(self.pos.xy);
        if ((self.pos.z - floorz) <= 0.0 && frandom(0.0, 1.0) > 0.5) {

        }
        */

		if (self.Alpha <= 0 || --self.c_lifetime <= 0 || (self.c_size <= 0)) {
            self.Remove();
		}

		self.c_velocity += self.c_accel;
        self.A_ChangeVelocity(self.c_velocity.x, self.c_velocity.y, self.c_velocity.z, CVF_REPLACE, AAPTR_DEFAULT);
    }

    virtual void Remove() {
        self.Destroy();
    }

    double FadeFromLifetime(double a) {
        return 1.0 / a;
    }
}