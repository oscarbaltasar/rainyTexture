-- Auto generated script file --

local RainyTexture = require("RainyTexture")
local myRainyTexture = RainyTexture.CreateTexture(textures:getTextures()[1],1, vec(0, 0, 1, 1), 0.1, 10, 20)
myRainyTexture.updateTrailTail(10)

--createTexture(textures:getTextures()[10],10, vec(0, 0, 0, 1), 0.1, 10, 20, {true,false,false,false,false,false,false,false,false,false,false,false,false,false,false,true,false,false,false,false,false,false,false,false,false,false,false,false,false,false})

function events.tick()
	myRainyTexture.updateSpawnColor(vec(math.random(), math.random(), math.random(), 1))
end
