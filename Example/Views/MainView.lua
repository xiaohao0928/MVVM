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
    local nameLabel = self._nameLabel
    local levelLabel = self._levelLabel
    local goldLabel = self._goldLabel
    local expLabel = self._expLabel
    local expBar = self._expBar
    local vm = self:getViewModel()
    
    -- 绑定名称
    self:bindVM("name", function(value)
        if nameLabel then
            nameLabel:setString(value or "")
        end
    end)
    
    -- 绑定等级
    self:bindVM("level", function(value)
        if levelLabel then
            levelLabel:setString("Lv." .. (value or 1))
        end
    end)
    
    -- 绑定金币
    self:bindVM("gold", function(value)
        if goldLabel then
            goldLabel:setString("金币: " .. (value or 0))
        end
    end)
    
    -- 绑定经验（多节点绑定同一属性示例）
    -- 1. 经验文本
    self:bindVM("exp", function(value)
        if expLabel then
            local maxExp = vm:get("maxExp") or 100
            expLabel:setString("经验: " .. (value or 0) .. "/" .. maxExp)
        end
    end)
    
    -- 2. 经验条
    self:bindVM("exp", function(value)
        if expBar then
            local maxExp = vm:get("maxExp") or 100
            local percent = (value or 0) / maxExp
            expBar:setPercent(percent * 100)
        end
    end)
end

return MainView
