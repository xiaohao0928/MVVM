--[[
    主界面ViewModel
    负责暴露属性给View绑定，并处理业务逻辑
]]

local ViewModel = require("MVVM.ViewModel")

local MainViewModel = class("MainViewModel", ViewModel)

function MainViewModel:onInitialize()
    -- 注册命令
    self:registerCommand("addGold", self.onAddGold)
    self:registerCommand("addExp", self.onAddExp)
    
    -- 绑定Model属性（自动同步到ViewModel）
    self:bindModelAll("user", {"name", "level", "gold", "exp", "maxExp"})
end

function MainViewModel:onAddGold(amount)
    local userModel = self:getModel("user")
    if userModel then
        userModel:addGold(amount or 100)
    end
end

function MainViewModel:onAddExp(amount)
    local userModel = self:getModel("user")
    if userModel then
        userModel:addExp(amount or 50)
    end
end

return MainViewModel
