local function getDistance(pt1, pt2)
	local result = math.sqrt((pt1.x-pt2.x)*(pt1.x-pt2.x) + (pt1.z-pt2.z)*(pt1.z-pt2.z))	-- 计算绝对距离
	return result
end

local function pointCanDeploy(inst, pt, mouseover)	-- 模拟原版能种植的判定
	local tiletype = TheWorld.Map:GetTileAtPoint(pt.x, pt.y, pt.z)		-- 获取所在位置的地皮类型
    local ground_OK = tiletype ~= GROUND.ROCKY
				  and tiletype ~= GROUND.ROAD
				  and tiletype ~= GROUND.IMPASSABLE
				  and tiletype ~= GROUND.UNDERROCK
				  and tiletype ~= GROUND.WOODFLOOR
				  and tiletype ~= GROUND.CARPET
				  and tiletype ~= GROUND.CHECKER
				  and tiletype < GROUND.UNDERGROUND
    if not ground_OK and (tiletype == GROUND.OCEAN_COASTAL or tiletype == GROUND.OCEAN_SWELL) then	-- 船上能种植，这里的OCEAN_COASTAL表示浅海面,OCEAN_SWELL表示深海
		ground_OK = true
	end
	
    if ground_OK then	-- 如果地皮能种植，再判断附近物品			cant tags
		local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 4, nil, {'NOBLOCK', 'player', 'FX'})
		
		local min_spacing = inst.replica.inventoryitem:DeploySpacingRadius()	-- 注意主客机
        
		if min_spacing == 0 then min_spacing = 1 end		-- 默认距离
        for k, v in pairs(ents) do
            if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil and v.prefab ~= "boat" then	-- 如果为船只则忽略
                if getDistance( Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing then
                    return false		-- 距离太近则无法种植
                end
            end
        end
		-- 种植间距满足后，再判断能否通过(以修复在海面上种植的问题)
		local platform = TheWorld.Map:GetPlatformAtPoint(pt.x, pt.y, pt.z)
		if platform ~= nil and platform.components.walkableplatform:CanBeWalkedOn() then
			return true
		end
		return TheWorld.Map:CanDeployAtPoint(pt, inst, mouseover)-- 这个一定要，上面那个platform只针对船
    end
	return false
end

AddComponentPostInit('deployable', function(self)
	local oldfn = self.CanDeploy
	function self:CanDeploy(pt, mouseover, deployer)
		if not self:IsDeployable(deployer) then
        	return false
    	elseif self.mode == DEPLOYMODE.PLANT then
			-- 此处原作者是判断能通过就能种植，这里我想改成原版的种植
    		-- local platform = TheWorld.Map:GetPlatformAtPoint(pt.x, pt.z)
    		-- if platform ~= nil and platform.components.walkableplatform:CanBeWalkedOn() then
        		-- return true
    		-- end
			return pointCanDeploy(self.inst, pt, mouseover)
        	-- return TheWorld.Map:CanDeployPlantAtPoint(pt, self.inst)
        else
        	return oldfn(self, pt, mouseover, deployer)
        end
    end
end)

-- 修改组件方法后，还需要修改replica
AddClassPostConstruct('components/inventoryitem_replica', function(self)
	local oldfn = self.CanDeploy
	function self:CanDeploy(pt, mouseover, deployer)
		if self.inst.components.deployable ~= nil then
			return self.inst.components.deployable:CanDeploy(pt, mouseover, deployer)
		elseif not self:IsDeployable(deployer) then
			return false
		elseif self.classified.deploymode:value() == DEPLOYMODE.PLANT then
			return pointCanDeploy(self.inst, pt)
		else
			return oldfn(self, pt, mouseover, deployer)
        end
    end
end)

AddPrefabPostInit("boat", function(inst)
	if not TheWorld.ismastersim then
		return inst
	end
	
	inst:RemoveComponent("burnable")		-- 移除可燃组件
	inst:RemoveComponent("fuel")
end)