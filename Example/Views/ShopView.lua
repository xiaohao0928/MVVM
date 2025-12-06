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
    local topGoldLabel = self._topGoldLabel
    local bottomGoldLabel = self._bottomGoldLabel
    local buyBtnGoldLabel = self._buyBtnGoldLabel
    local goldIconLabel = self._goldIconLabel
    local priceLabel = self._priceLabel
    local buyBtn = self._buyBtn
    local vm = self:getViewModel()
    
    -- 多个节点绑定同一个 gold 属性
    -- 1. 顶部显示
    self:bindVM("gold", function(value)
        if topGoldLabel then
            topGoldLabel:setString(tostring(value or 0))
        end
    end)
    
    -- 2. 底部显示
    self:bindVM("gold", function(value)
        if bottomGoldLabel then
            bottomGoldLabel:setString("拥有金币: " .. (value or 0))
        end
    end)
    
    -- 3. 购买按钮提示
    self:bindVM("gold", function(value)
        if buyBtnGoldLabel then
            buyBtnGoldLabel:setString("余额: " .. (value or 0))
        end
    end)
    
    -- 4. 金币图标旁（带千位分隔符）
    self:bindVM("gold", function(value)
        if goldIconLabel then
            local formatted = tostring(value or 0):reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
            goldIconLabel:setString(formatted)
        end
    end)
    
    -- 5. 购买按钮状态
    self:bindVM("gold", function(value)
        if buyBtn then
            local price = vm:get("itemPrice") or 100
            buyBtn:setEnabled((value or 0) >= price)
        end
    end)
    
    -- 绑定价格
    self:bindVM("itemPrice", function(value)
        if priceLabel then
            priceLabel:setString("价格: " .. (value or 0))
        end
    end)
end

return ShopView
