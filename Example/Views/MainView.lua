--[[
    主界面View
]]

local View = require("MVVM.View")

local MainView = class("MainView", View)

function MainView:onInitialize()
    -- 获取csb中的节点
    self._nameLabel = self:getChild("nameLabel")
    self._levelLabel = self:getChild("levelLabel")
    self._goldLabel = self:getChild("goldLabel")
    self._expLabel = self:getChild("expLabel")
    self._expBar = self:getChild("expBar")
    self._addGoldBtn = self:getChild("addGoldBtn")
    self._addExpBtn = self:getChild("addExpBtn")
    
    -- 绑定按钮事件
    if self._addGoldBtn then
        self._addGoldBtn:addClickEventListener(function()
            self:getViewModel():executeCommand("addGold", 100)
        end)
    end
    
    if self._addExpBtn then
        self._addExpBtn:addClickEventListener(function()
            self:getViewModel():executeCommand("addExp", 50)
        end)
    end
end

function MainView:onBindViewModel()
    -- 绑定名称
    self:bind("user", "name", self._nameLabel, function(label, value)
        if label then
            label:setString(value or "")
        end
    end)
    
    -- 绑定等级
    self:bind("user", "level", self._levelLabel, function(label, value)
        if label then
            label:setString("Lv." .. (value or 1))
        end
    end)
    
    -- 绑定金币
    self:bind("user", "gold", self._goldLabel, function(label, value)
        if label then
            label:setString("金币: " .. (value or 0))
        end
    end)
    
    -- 绑定经验
    self:bind("user", "exp", self._expLabel, function(label, value, oldValue)
        if label then
            local vm = self:getViewModel()
            local maxExp = vm:getModel("user"):get("maxExp")
            label:setString(string.format("经验: %d/%d", value or 0, maxExp or 100))
        end
    end)
    
    -- 绑定经验条
    self:bind("user", "exp", self._expBar, function(bar, value)
        if bar then
            local vm = self:getViewModel()
            local maxExp = vm:getModel("user"):get("maxExp")
            local percent = (value or 0) / (maxExp or 100)
            bar:setPercent(percent * 100)
        end
    end)
end

return MainView

