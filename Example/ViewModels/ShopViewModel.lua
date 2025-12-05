--[[
    商店界面ViewModel
]]

local ViewModel = require("MVVM.ViewModel")

local ShopViewModel = class("ShopViewModel", ViewModel)

function ShopViewModel:onInitialize()
    -- 注册命令
    self:registerCommand("buyItem", self.onBuyItem)
end

function ShopViewModel:onBuyItem()
    local userModel = self:getModel("user")
    local shopModel = self:getModel("shop")
    
    if not userModel or not shopModel then
        return
    end
    
    local gold = userModel:get(PropertyName.gold) or 0
    local price = shopModel:get(PropertyName.itemPrice) or 100
    
    if gold >= price then
        -- 扣除金币
        userModel:set(PropertyName.gold, gold - price)
        print("[ShopViewModel] 购买成功！剩余金币: " .. (gold - price))
    else
        print("[ShopViewModel] 金币不足！")
    end
end

return ShopViewModel

