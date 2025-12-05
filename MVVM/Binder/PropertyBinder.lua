--[[
    属性绑定器 - 提供常用UI属性的便捷绑定方法
]]

local Binder = require("MVVM.Binder")

local PropertyBinder = class("PropertyBinder", Binder)

function PropertyBinder:ctor()
    PropertyBinder.super.ctor(self)
end

--[[
    绑定文本
    @param modelName string Model名称
    @param propertyName string 属性名
    @param label cc.Label 文本节点
    @param format string 格式化字符串（可选）
    @return PropertyBinder
]]
function PropertyBinder:bindText(modelName, propertyName, label, format)
    return self:bind(modelName, propertyName, label, function(node, value, oldValue)
        if format then
            node:setString(string.format(format, value or ""))
        else
            node:setString(tostring(value or ""))
        end
    end)
end

--[[
    绑定可见性
    @param modelName string Model名称
    @param propertyName string 属性名
    @param node cc.Node 节点
    @param invert boolean 是否反转（可选）
    @return PropertyBinder
]]
function PropertyBinder:bindVisible(modelName, propertyName, node, invert)
    return self:bind(modelName, propertyName, node, function(n, value, oldValue)
        local visible = value and true or false
        if invert then
            visible = not visible
        end
        n:setVisible(visible)
    end)
end

--[[
    绑定启用状态（按钮等）
    @param modelName string Model名称
    @param propertyName string 属性名
    @param button ccui.Button 按钮节点
    @return PropertyBinder
]]
function PropertyBinder:bindEnabled(modelName, propertyName, button)
    return self:bind(modelName, propertyName, button, function(node, value, oldValue)
        node:setEnabled(value and true or false)
    end)
end

--[[
    绑定透明度
    @param modelName string Model名称
    @param propertyName string 属性名
    @param node cc.Node 节点
    @return PropertyBinder
]]
function PropertyBinder:bindOpacity(modelName, propertyName, node)
    return self:bind(modelName, propertyName, node, function(n, value, oldValue)
        n:setOpacity(value or 255)
    end)
end

--[[
    绑定颜色
    @param modelName string Model名称
    @param propertyName string 属性名
    @param node cc.Node 节点
    @return PropertyBinder
]]
function PropertyBinder:bindColor(modelName, propertyName, node)
    return self:bind(modelName, propertyName, node, function(n, value, oldValue)
        if value then
            n:setColor(cc.c3b(value.r or 255, value.g or 255, value.b or 255))
        end
    end)
end

--[[
    绑定缩放
    @param modelName string Model名称
    @param propertyName string 属性名
    @param node cc.Node 节点
    @return PropertyBinder
]]
function PropertyBinder:bindScale(modelName, propertyName, node)
    return self:bind(modelName, propertyName, node, function(n, value, oldValue)
        n:setScale(value or 1)
    end)
end

--[[
    绑定精灵图片
    @param modelName string Model名称
    @param propertyName string 属性名
    @param sprite cc.Sprite 精灵节点
    @return PropertyBinder
]]
function PropertyBinder:bindSprite(modelName, propertyName, sprite)
    return self:bind(modelName, propertyName, sprite, function(node, value, oldValue)
        if value and value ~= "" then
            node:setTexture(value)
        end
    end)
end

--[[
    绑定精灵帧
    @param modelName string Model名称
    @param propertyName string 属性名
    @param sprite cc.Sprite 精灵节点
    @return PropertyBinder
]]
function PropertyBinder:bindSpriteFrame(modelName, propertyName, sprite)
    return self:bind(modelName, propertyName, sprite, function(node, value, oldValue)
        if value and value ~= "" then
            local frame = cc.SpriteFrameCache:getInstance():getSpriteFrame(value)
            if frame then
                node:setSpriteFrame(frame)
            end
        end
    end)
end

--[[
    绑定进度条
    @param modelName string Model名称
    @param propertyName string 属性名
    @param progressBar ccui.LoadingBar 进度条节点
    @return PropertyBinder
]]
function PropertyBinder:bindProgress(modelName, propertyName, progressBar)
    return self:bind(modelName, propertyName, progressBar, function(node, value, oldValue)
        node:setPercent(value or 0)
    end)
end

--[[
    绑定位置
    @param modelName string Model名称
    @param propertyName string 属性名
    @param node cc.Node 节点
    @return PropertyBinder
]]
function PropertyBinder:bindPosition(modelName, propertyName, node)
    return self:bind(modelName, propertyName, node, function(n, value, oldValue)
        if value then
            n:setPosition(value.x or 0, value.y or 0)
        end
    end)
end

--[[
    绑定旋转
    @param modelName string Model名称
    @param propertyName string 属性名
    @param node cc.Node 节点
    @return PropertyBinder
]]
function PropertyBinder:bindRotation(modelName, propertyName, node)
    return self:bind(modelName, propertyName, node, function(n, value, oldValue)
        n:setRotation(value or 0)
    end)
end

--[[
    绑定列表数据
    @param modelName string Model名称
    @param propertyName string 属性名
    @param listView ccui.ListView 列表节点
    @param itemCreator function 创建列表项函数 function(data, index) return node end
    @return PropertyBinder
]]
function PropertyBinder:bindList(modelName, propertyName, listView, itemCreator)
    return self:bind(modelName, propertyName, listView, function(node, value, oldValue)
        node:removeAllItems()
        if value and type(value) == "table" then
            for i, data in ipairs(value) do
                local item = itemCreator(data, i)
                if item then
                    node:pushBackCustomItem(item)
                end
            end
        end
    end)
end

--[[
    条件绑定 - 根据条件执行不同的更新
    @param modelName string Model名称
    @param propertyName string 属性名
    @param node cc.Node 节点
    @param conditions table 条件表 {{condition = func, update = func}, ...}
    @return PropertyBinder
]]
function PropertyBinder:bindCondition(modelName, propertyName, node, conditions)
    return self:bind(modelName, propertyName, node, function(n, value, oldValue)
        for i = 1, #conditions do
            local cond = conditions[i]
            if cond.condition(value) then
                cond.update(n, value)
                return
            end
        end
    end)
end

return PropertyBinder

