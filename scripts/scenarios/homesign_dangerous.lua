local function OnCreate(inst, scenariorunner)
    inst:AddTag("named_homesign")
    -- inst.components.writeable.text = "dangerous places"
end

local function OnLoad(inst, scenariorunner)
end

local function OnDestroy(inst)
end

return
{
    OnCreate = OnCreate,
    OnLoad = OnLoad,
    OnDestroy = OnDestroy
}
