--[[
    示例UI配置
]]

local MainView = require("Example.Views.MainView")
local MainViewModel = require("Example.ViewModels.MainViewModel")
local ShopView = require("Example.Views.ShopView")
local ShopViewModel = require("Example.ViewModels.ShopViewModel")

local UID = {
    MAIN = 1,
    SHOP = 2,
}

return {
    UID = UID,
    views = {
        {
            id = UID.MAIN,
            name = "主界面",
            csb = "res/MainView.csb",
            zOrder = 0,
            viewClass = MainView,
            viewModelClass = MainViewModel,
        },
        {
            id = UID.SHOP,
            name = "商店界面",
            csb = "res/ShopView.csb",
            zOrder = 10,
            viewClass = ShopView,
            viewModelClass = ShopViewModel,
        },
    },
}

