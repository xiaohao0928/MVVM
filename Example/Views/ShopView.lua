--[[
    商店界面View - 演示多个节点绑定同一属性
]]

local View = require("MVVM.View")

local ShopView = class("ShopView", View)

function ShopView:onInitialize()
    -- 顶部金币显示
    self._topGoldLabel = self:getChild("topGoldLabel")
    -- 底部金币显示
    self._bottomGoldLabel = self:getChild("bottomGoldLabel")
    -- 购买按钮上的金币提示
    self._buyBtnGoldLabel = self:getChild("buyBtnGoldLabel")
    -- 金币图标旁的数字
    self._goldIconLabel = self:getChild("goldIconLabel")
    
    -- 商品价格
    self._priceLabel = self:getChild("priceLabel")
    -- 购买按钮
    self._buyBtn = self:getChild("buyBtn")
    
    -- 绑定购买事件
    if self._buyBtn then
        self._buyBtn:addClickEventListener(function()
            self:getViewModel():executeCommand("buyItem")
        end)
    end
end

function ShopView:onBindViewModel()
    -- 多个节点绑定同一个 gold 属性
    -- 1. 顶部显示
    self:bind("user", "gold", self._topGoldLabel, function(label, value)
        if label then
            label:setString(string.format("%d", value or 0))
        end
    end)
    
    -- 2. 底部显示（带格式化）
    self:bind("user", "gold", self._bottomGoldLabel, function(label, value)
        if label then
            label:setString(string.format("拥有金币: %d", value or 0))
        end
    end)
    
    -- 3. 购买按钮提示
    self:bind("user", "gold", self._buyBtnGoldLabel, function(label, value)
        if label then
            label:setString(string.format("余额: %d", value or 0))
        end
    end)
    
    -- 4. 金币图标旁（带千位分隔符）
    self:bind("user", "gold", self._goldIconLabel, function(label, value)
        if label then
            local formatted = tostring(value or 0):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
            label:setString(formatted)
        end
    end)
    
    -- 5. 购买按钮状态也受金币影响
    self:bind("user", "gold", self._buyBtn, function(btn, value)
        if btn then
            local price = 100 -- 假设商品价格100
            btn:setEnabled((value or 0) >= price)
        end
    end)
    
    -- 绑定价格
    self:bind("shop", "itemPrice", self._priceLabel, function(label, value)
        if label then
            label:setString(string.format("价格: %d", value or 0))
        end
    end)
end

return ShopView

