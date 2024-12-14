local RainyTexture = {}

--- Turns a texture into a procedurally generated "rainlike" texture
---@param texture The texture to rainify
---@param trailTail The lenght of the raindrops
---@param spawnColor The color of the raindrops
---@param spawnChance The chance to spawn a raindrop every attempt (0 - 1)
---@param spawnCooldownMin Minimum ticks for an attempt at spawn to happen
---@param spawnCooldownMax Maximum ticks for an attempt at spawn to happen
---@param createColumns Optional boolean list to skip some columns in the texture. Ej: { true, false, false, false, false, false, false, true}
---@return SwingHandler
function RainyTexture.CreateTexture(texture, trailTail, spawnColor, spawnChance, spawnCooldownMin, spawnCooldownMax, createColumns)
    local handler = {}
	-- Column class
    local Column = {}
    Column.__index = Column
	
	-->>>>>>>>>>>>>>>>>>>>>>>>> Parameters
    handler.rainyTexture = texture
    handler.trailLength = trailTail or 10
    handler.spawnColor = spawnColor or vec(0, 0, 1, 1)
    handler.spawnChance = spawnChance or 0.1
    handler.spawnCooldownMin = spawnCooldownMin or 10
    handler.spawnCooldownMax = spawnCooldownMax or 20
    handler.Columns = {}
    handler.createColumns = createColumns or nil
	
	-->>>>>>>>>>>>>>>>>>>>>>>>> Local variables
	
    local textureHeight = texture:getDimensions().y - 1
    local textureWidth = texture:getDimensions().x - 1

    
    
	-->>>>>>>>>>>>>>>>>>>>>>>>> Create functions
	
	--- Creates a new column
	---@param x x position for the whole column
	---@param spawnColor The color new pixels will have
    function Column:new(x, spawnColor)
        return setmetatable({
            vertices = {},
            x = x,
            fadedCounter = -1,
            clearRgba = vec(0, 0, 0, 1),
            spawnRgba = vec(spawnColor.x, spawnColor.y, spawnColor.z, spawnColor.w),
            spawnCooldown = math.random(handler.spawnCooldownMin, handler.spawnCooldownMax),
        }, Column)
    end

	--- Creates a new vertex inside a column
    function Column:spawn()
        if #self.vertices < textureHeight / handler.trailLength then
            table.insert(self.vertices, { y = 0, rgba = vec(self.spawnRgba.x, self.spawnRgba.y, self.spawnRgba.z, self.spawnRgba.w) })
        end
    end

	-->>>>>>>>>>>>>>>>>>>>>>>>> Tick functions
	
	--- Updates a column's vertex and faded vertex colors and positions (The meat of the logic)
    function Column:updatePositions()
        -- Move all vertices downward
        for i = #self.vertices, 1, -1 do
            local vertex = self.vertices[i]
            
            -- Set pixel at the current position
            handler.rainyTexture:setPixel(self.x, vertex.y, vertex.rgba)
            
            -- Paint a fading trail above the vertex
            for j = vertex.y - 1, math.max(vertex.y - handler.trailLength, 0), -1 do
                local fadeFactor = (vertex.y - j) / handler.trailLength
                local fadedColor = vec(vertex.rgba.x * (1 - fadeFactor), vertex.rgba.y * (1 - fadeFactor), vertex.rgba.z * (1 - fadeFactor), vertex.rgba.w * (1 - fadeFactor))
                handler.rainyTexture:setPixel(self.x, j, fadedColor)
            end
            
            -- Move the vertex down
            vertex.y = vertex.y + 1
            
            -- Remove vertex if it exits the texture
            if vertex.y > textureHeight then
                self.clearRgba = vec(vertex.rgba.x, vertex.rgba.y, vertex.rgba.z, vertex.rgba.w)
                table.remove(self.vertices, i)
                self.fadedCounter = handler.trailLength
            end
        end
        
        -- Paint over already faded pixels at the bottom
		for i = self.fadedCounter, 0, -1 do
			local colorFadeFactor = (i) / handler.trailLength
			local fadeFactor = (self.fadedCounter - i) / handler.trailLength
			local fadedColor = vec(
				self.clearRgba.x * (1 - colorFadeFactor),
				self.clearRgba.y * (1 - colorFadeFactor),
				self.clearRgba.z * (1 - colorFadeFactor),
				self.clearRgba.w * (fadeFactor - 1)
			)
			handler.rainyTexture:setPixel(self.x, textureHeight - i, fadedColor)
		end
		
        self.fadedCounter = self.fadedCounter - 1
        if self.fadedCounter < -1 then
            self.fadedCounter = -1
        end
    end

	--- Handles spawn conditions for new vertex in a column
    function Column:update()
        self.spawnCooldown = self.spawnCooldown - 1
        if self.spawnCooldown <= 0 then
            if math.random() < handler.spawnChance then
                self:spawn()
            end
            self.spawnCooldown = math.random(handler.spawnCooldownMin, handler.spawnCooldownMax)
        end
        self:updatePositions()
    end
    
	--- Minecraft tick loop
	function events.tick()
        for _, column in ipairs(handler.Columns) do
            column:update()
        end
		
		-- Update the texture in memory to reflect all changes
        handler.rainyTexture:update()
    end

	-->>>>>>>>>>>>>>>>>>>>>>>>> Initialize all columns
	
    local totalColumns = 0
    if handler.createColumns then
        for i = #handler.createColumns, 1, -1 do
            if handler.createColumns[i] == true then
                totalColumns = totalColumns + 1
            end
        end
    else
        totalColumns = textureWidth
    end

    local currentX = 1
    for i = 1, totalColumns do
        if handler.createColumns then
            for x = currentX, #handler.createColumns, 1 do
                if handler.createColumns[x] == true then
                    currentX = x + 1
                    handler.Columns[i] = Column:new(x - 1, handler.spawnColor)
                    break
                end
            end
        else
            handler.Columns[i] = Column:new(i - 1, handler.spawnColor)
        end
    end

    -->>>>>>>>>>>>>>>>>>>>>>>>> Update functions
	
	--- Updates the leftover trail left by pixels
	---@param newTrailTail New lenght
	---@note Changing this to a lower value while the texture has pixels will can cause leftover trails that will not be cleaned automatically!
    function handler.updateTrailTail(newTrailTail)
        handler.trailLength = newTrailTail
    end

	--- Updates the spawn color for new pixels
	---@param newSpawnColor New color
    function handler.updateSpawnColor(newSpawnColor)
        handler.spawnColor = newSpawnColor
        for _, column in ipairs(handler.Columns) do
            column.spawnRgba = vec(newSpawnColor.x, newSpawnColor.y, newSpawnColor.z, newSpawnColor.w)
        end
    end

	--- Updates the spawn chance each attempt
	---@param newCooldownMin New spawn chance (0 - 1)
    function handler.updateSpawnChance(newSpawnChance)
        handler.spawnChance = newSpawnChance
    end

	--- Updates the min cooldown between spawn attempts
	---@param newCooldownMin New min spawn tick timer
    function handler.updateSpawnCooldownMin(newCooldownMin)
        handler.spawnCooldownMin = newCooldownMin
    end
	
	--- Updates the max cooldown between spawn attempts
	---@param newCooldownMax New max spawn tick timer
    function handler.updateSpawnCooldownMax(newCooldownMax)
        handler.spawnCooldownMax = newCooldownMax
    end

    return handler
end

return RainyTexture
