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