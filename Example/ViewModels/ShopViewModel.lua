--[[
    商店界面ViewModel
    负责暴露属性给View绑定，并处理业务逻辑
]]

local ViewModel = require("MVVM.ViewModel")

local ShopViewModel = class("ShopViewModel", ViewModel)

function ShopViewModel:onInitialize()
    -- 注册命令
    self:registerCommand("buyItem", self.onBuyItem)
    
    -- 绑定Model属性（自动同步到ViewModel）
    self:bindModel("user", "gold")
    self:bindModelAll("shop", {"itemPrice", "itemName"})
end

function ShopViewModel:onBuyItem()
    local userModel = self:getModel("user")
    local shopModel = self:getModel("shop")
    
    if not userModel or not shopModel then
        return
    end
    
    local gold = userModel:get("gold") or 0
    local price = shopModel:get("itemPrice") or 100
    
    if gold >= price then
        -- 扣除金币
        userModel:set("gold", gold - price)
        print("[ShopViewModel] 购买成功！剩余金币: " .. (gold - price))
    else
        print("[ShopViewModel] 金币不足！")
    end
end

return ShopViewModel
