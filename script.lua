-- Module initialisation, it MUST be created this way --

local RainyTexture = require("RainyTexture")
local myRainyTexture = RainyTexture.CreateTexture(textures:getTextures()[1],1, vec(0, 0, 1, 1), 0.1, 10, 20, 1)

-- Example with individual column enable and disable
--createTexture(textures:getTextures()[1],1, vec(0, 0, 1, 1), 0.1, 10, 20, 1, {true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false})


-- Update trail after initialisation
myRainyTexture.updateTrailTail(10)



function events.tick()
	-- Update color each tick
	myRainyTexture.updateSpawnColor(vec(math.random(), math.random(), math.random(), 1))
end
