-- local UIAnim = require "widgets/uianim"
-- local Text = require "widgets/text"
local Widget = require "widgets/widget"
local Image = require "widgets/image"
local ImageButton = require "widgets/imagebutton"
-- local AnimButton = require "widgets/animbutton"
-- local HoverText = require "widgets/hoverer"
-- require "utils/bu_shadow_chest_find"
-- require "networkclientrpc"
require "client/auto_fishing"

local bu_ui_shadowbox = Class(Widget, function(self)
	Widget._ctor(self, "bu_ui_shadowbox")
    
    self.mainbutton = self:AddChild(ImageButton("images/button/skull_chest_btn.xml", "skull_chest_btn.tex"))
	self.mainbutton:SetPosition(-850, -475, 0)
	self.mainbutton:SetScale(0.75, 0.75, 0.75)
    -- self.mainbutton:MoveToFront()    -- 这个操作由调用者去做
    self.mainbutton:SetHoverText("看看我的末影箱在哪里")

    self.mainbutton:SetOnClick(function()
        local function SayString(data)
            local str = ThePlayer._key_point and ThePlayer._key_point:value() or ""
            ThePlayer.components.talker:Say(str)
            ThePlayer:RemoveEventCallback("key_point_dirty", SayString)
        end

        SendModRPCToServer(MOD_RPC["XiaoBu_Server"]["shadow_box_info"], ThePlayer)
        print("send rpc ok!")
        ThePlayer:ListenForEvent("key_point_dirty", SayString)
    end)

    self.fishing_button = self:AddChild(ImageButton("images/inventoryimages1.xml", "fishingrod.tex"))
	self.fishing_button:SetPosition(-790, -475, 0)
	self.fishing_button:SetScale(0.75, 0.75, 0.75)
    self.fishing_button:SetHoverText("自动钓鱼！")

    self.fishing_button:SetOnClick(function()
        -- print("clicked! ")
        Bu_AutoFishing_Start()
    end)
end)

return bu_ui_shadowbox
