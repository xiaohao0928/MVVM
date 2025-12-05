--[[
    用户数据模型
]]

local Model = require("MVVM.Model")
local UserModel = class("UserModel", Model)

function UserModel:onInitialize()
    self:set("name", "游客")
    self:set("level", 1)
    self:set("gold", 1000)
    self:set("exp", 0)
    self:set("maxExp", 100)
    self:computed("expPercent", function()
        return self:get("exp") / self:get("maxExp")
    end)
    self:computed("expPercentText", function()
        return string.format("%.2f%%", self:get("expPercent") * 100)
    end)
end

function UserModel:addGold(amount)
    self:set("gold", self:get("gold") + amount)
end

function UserModel:addExp(amount)
    local exp = self:get("exp") + amount
    local maxExp = self:get("maxExp")
    
    while exp >= maxExp do
        exp = exp - maxExp
        local level = self:get("level") + 1
        self:set("level", level)
        maxExp = level * 100
        self:set("maxExp", maxExp)
    end
    
    self:set("exp", exp)
end

return UserModel

