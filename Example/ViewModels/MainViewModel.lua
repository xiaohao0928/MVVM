--[[
    主界面ViewModel
]]

local ViewModel = require("MVVM.ViewModel")

local MainViewModel = class("MainViewModel", ViewModel)

function MainViewModel:onInitialize()
    -- 注册命令
    self:registerCommand("addGold", self.onAddGold)
    self:registerCommand("addExp", self.onAddExp)
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

