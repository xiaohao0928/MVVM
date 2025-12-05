--[[
    示例Model配置
]]

local UserModel = require("Example.Models.UserModel")
local ShopModel = require("Example.Models.ShopModel")

local MID = {
    USER = "user",
    SHOP = "shop",
}

return {
    MID = MID,
    models = {
        {
            id = MID.USER,
            class = UserModel,
        },
        {
            id = MID.SHOP,
            class = ShopModel,
        },
    },
}

