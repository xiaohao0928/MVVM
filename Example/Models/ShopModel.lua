--[[
    商店Model
]]

local Model = require("MVVM.Model")

local ShopModel = class("ShopModel", Model)

local PropertyName = {
    itemPrice = "itemPrice",
    itemName = "itemName",
}

function ShopModel:onInitialize()
    -- 初始化商品价格
    self:set(PropertyName.itemPrice, 100)
    self:set(PropertyName.itemName, "神秘道具")
end

--[[
    设置商品价格
    @param price number 价格
]]
function ShopModel:setItemPrice(price)
    self:set(PropertyName.itemPrice, price)
end

return ShopModel

