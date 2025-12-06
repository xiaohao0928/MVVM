--[[
    可观察对象基类 - 提供属性监听和通知功能
]]

local table_remove = table.remove

local Observable = class("Observable")

function Observable:ctor()
    -- 存储属性值
    self._properties = {}

    -- 存储属性监听器
    self._observers = {}
end

--[[
    设置属性值
    @param key string 属性名
    @param value any 属性值
    @param mode number 模式：1强制 2静默
]]
function Observable:set(key, value, mode)
    local properties = self._properties
    local oldValue = properties[key]
    
    -- 值没有变化则不处理（强制模式跳过此检查）
    if mode ~= 1 and oldValue == value then
        return
    end
    
    properties[key] = value
    
    -- 静默模式不通知
    if mode == 2 then
        return
    end
    
    -- 通知观察者
    local observers = self._observers[key]
    if observers then
        for i = 1, #observers do
            observers[i](value, oldValue)
        end
    end
end

--[[
    获取属性值
    @param key string 属性名
    @return any 属性值
]]
function Observable:get(key)
    return self._properties[key]
end

--[[
    批量设置属性
    @param data table 属性键值对
    @param mode number 模式：1强制 2静默
]]
function Observable:setData(data, mode)
    for key, value in pairs(data) do
        self:set(key, value, mode)
    end
end

--[[
    获取所有属性数据
    @return table 属性数据
]]
function Observable:getData()
    return self._properties
end

--[[
    监听属性变化
    @param key string 属性名
    @param callback function 回调函数 callback(newValue, oldValue)
    @return function 返回取消监听的函数
]]
function Observable:observe(key, callback)
    if not self._observers[key] then
        self._observers[key] = {}
    end
    
    self._observers[key][#self._observers[key] + 1] = callback
    
    -- 返回取消监听的函数
    return function()
        self:unobserve(key, callback)
    end
end

--[[
    取消监听属性变化
    @param key string 属性名
    @param callback function 要移除的回调函数
]]
function Observable:unobserve(key, callback)
    if not self._observers[key] then
        return
    end
    
    for i = #self._observers[key], 1, -1 do
        if self._observers[key][i] == callback then
            table_remove(self._observers[key], i)
        end
    end
end

--[[
    销毁对象，清理所有监听器
]]
function Observable:destroy()
    self._observers = {}
    self._properties = {}
end

return Observable
