local EFFECT = {}

function EFFECT:Init( data ) 
	local pos = data:GetStart()
	local emit = ParticleEmitter(pos)
	sound.Play("garrysmod/save_load1.wav", pos)

	for i = 0, 60 do
		local glow = emit:Add( "sprites/glow04_noz", pos + Vector(math.Rand(-16, 16), math.Rand(-16, 16), math.Rand(0, 70)))
		glow:SetVelocity(VectorRand()*10)
		glow:SetDieTime(math.Rand(.5,1))
		glow:SetStartAlpha(math.Rand(222,255))
		glow:SetEndAlpha(0)
		glow:SetStartSize(math.random(0,5))
		glow:SetEndSize(math.random(10,20))
		glow:SetRoll(math.Rand(180,480))
		glow:SetRollDelta(math.Rand(-3,3))
		glow:SetColor(250,250,250)
		glow:SetGravity( Vector( 0, 0, 10 ) )
		glow:SetAirResistance(200)
	end
end 
   
function EFFECT:Think( )
end

function EFFECT:Render()
end

effects.Register( EFFECT, "FeatherJob" )

local EFFECT = {}
EFFECT.Debris = {
	"models/Gibs/wood_gib01a.mdl",
	"models/Gibs/wood_gib01b.mdl",
	"models/Gibs/wood_gib01c.mdl",
	"models/Gibs/wood_gib01d.mdl",
	"models/Gibs/wood_gib01e.mdl",
}

function EFFECT:Init( data ) 
	local pos = data:GetStart()	
	self.emitter = ParticleEmitter(Vector(0, 0, 0))

	for i = 0, 15 do
		local smoke = self.emitter:Add( "particle/smokesprites_000"..math.random(1,9), pos + VectorRand()*10)
		smoke:SetVelocity(VectorRand()*100)
		smoke:SetDieTime(math.Rand(.5,.9))
		smoke:SetStartAlpha(math.Rand(222,255))
		smoke:SetEndAlpha(0)
		smoke:SetStartSize(math.random(0,5))
		smoke:SetEndSize(math.random(22,44))
		smoke:SetRoll(math.Rand(180,480))
		smoke:SetRollDelta(math.Rand(-3,3))
		smoke:SetColor(80, 60, 0)
		smoke:SetGravity( Vector( 0, 0, 20 ) )
		smoke:SetAirResistance(250)
	end

	self.DebrisEnt = {}
	for i = 1, 5 do
		local debris = ClientsideModel(table.Random(self.Debris))
		local vec = Vector(10, 1, 2)
		local rand = math.Rand(.6, .7)
		debris:SetPos(pos + VectorRand()*15)
		debris:PhysicsInitBox( -vec*rand, vec*rand )
		debris.lifeTime = CurTime() + 1
		debris.alpha = 255
		debris:SetModelScale(debris:GetModelScale()*rand, 0)
		debris:SetAngles(AngleRand())
		debris:SetRenderMode(RENDERMODE_TRANSALPHA)

		local p = debris:GetPhysicsObject()
		if( p and p:IsValid()) then
			p:SetVelocity(VectorRand()*150)
			p:AddAngleVelocity(VectorRand()*500)
		end

		timer.Simple(1, function()
			if debris:IsValid() then
				debris:Remove()
			end
		end)
	end
end

effects.Register( EFFECT, "FeatherDestroy" )