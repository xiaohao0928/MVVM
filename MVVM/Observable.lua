--[[
    可观察对象基类 - 提供属性监听和通知功能
]]

-- 本地化全局函数
local pairs = pairs
local type = type
local table_remove = table.remove

local Observable = class("Observable")

function Observable:ctor()
    -- 存储属性值
    self._properties = {}
    -- 存储属性监听器
    self._observers = {}
    -- 存储计算属性 {getter, dependencies, cachedValue}
    self._computed = {}
    -- 存储依赖关系 {dependencyKey = {computedKey1, computedKey2, ...}}
    self._dependencyMap = {}
    -- 批量更新标记
    self._batchUpdate = false
    -- 批量更新期间待更新的计算属性
    self._pendingComputed = {}
end

--[[
    设置属性值
    @param key string 属性名
    @param value any 属性值
    @param silent boolean 是否静默设置（不触发通知）
]]
function Observable:set(key, value, silent)
    local properties = self._properties
    local oldValue = properties[key]
    
    -- 值没有变化则不处理
    if oldValue == value then
        return
    end
    
    properties[key] = value
    
    -- 静默模式直接返回
    if silent then
        return
    end
    
    -- 通知观察者（内联优化，避免函数调用）
    local observers = self._observers[key]
    if observers then
        for i = 1, #observers do
            observers[i](value, oldValue)
        end
    end
    
    -- 更新依赖于此属性的计算属性
    local dependents = self._dependencyMap[key]
    if dependents then
        self:_updateDependentComputed(key)
    end
end

--[[
    获取属性值（高频调用，已优化）
    @param key string 属性名
    @return any 属性值
]]
function Observable:get(key)
    -- 先检查计算属性（通常较少）
    local computed = self._computed[key]
    if computed then
        return computed.cachedValue
    end
    -- 从普通属性获取
    return self._properties[key]
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
    通知所有观察者
    @param key string 属性名
    @param newValue any 新值
    @param oldValue any 旧值
]]
function Observable:_notify(key, newValue, oldValue)
    local observers = self._observers[key]
    if not observers then
        return
    end
    
    for i = 1, #observers do
        observers[i](newValue, oldValue)
    end
end

--[[
    定义计算属性
    @param key string 属性名
    @param dependencies table 依赖的属性名列表
    @param getter function 计算函数 function(self) return value end
]]
function Observable:computed(key, dependencies, getter)
    -- 兼容旧的调用方式 computed(key, getter)
    if type(dependencies) == "function" then
        getter = dependencies
        dependencies = {}
    end
    
    -- 计算初始值
    local initialValue = getter(self)
    
    -- 保存计算属性信息
    self._computed[key] = {
        getter = getter,
        dependencies = dependencies,
        cachedValue = initialValue
    }
    
    -- 建立依赖关系映射
    for i = 1, #dependencies do
        local depKey = dependencies[i]
        if not self._dependencyMap[depKey] then
            self._dependencyMap[depKey] = {}
        end
        local depList = self._dependencyMap[depKey]
        depList[#depList + 1] = key
    end
end

--[[
    更新依赖于指定属性的所有计算属性
    @param key string 被依赖的属性名
]]
function Observable:_updateDependentComputed(key)
    local dependents = self._dependencyMap[key]
    if not dependents then
        return
    end
    
    for i = 1, #dependents do
        local computedKey = dependents[i]
        
        -- 批量更新模式：只标记，不立即计算
        if self._batchUpdate then
            self._pendingComputed[computedKey] = true
        else
            local computed = self._computed[computedKey]
            if computed then
                local oldValue = computed.cachedValue
                local newValue = computed.getter(self)
                
                -- 只有值变化时才更新和通知
                if oldValue ~= newValue then
                    computed.cachedValue = newValue
                    self:_notify(computedKey, newValue, oldValue)
                    -- 递归更新依赖于此计算属性的其他计算属性
                    self:_updateDependentComputed(computedKey)
                end
            end
        end
    end
end

--[[
    批量设置属性（优化：只在最后统一更新计算属性）
    @param data table 属性键值对
    @param silent boolean 是否静默设置
]]
function Observable:setData(data, silent)
    self._batchUpdate = true
    self._pendingComputed = {}
    
    for key, value in pairs(data) do
        self:set(key, value, silent)
    end
    
    self._batchUpdate = false
    
    -- 统一更新所有待更新的计算属性
    if not silent then
        self:_flushPendingComputed()
    end
end

--[[
    开始批量更新
]]
function Observable:beginBatch()
    self._batchUpdate = true
    self._pendingComputed = {}
end

--[[
    结束批量更新，统一计算
]]
function Observable:endBatch()
    self._batchUpdate = false
    self:_flushPendingComputed()
end

--[[
    刷新待更新的计算属性
]]
function Observable:_flushPendingComputed()
    local pending = self._pendingComputed
    self._pendingComputed = {}
    
    for computedKey in pairs(pending) do
        local computed = self._computed[computedKey]
        if computed then
            local oldValue = computed.cachedValue
            local newValue = computed.getter(self)
            
            if oldValue ~= newValue then
                computed.cachedValue = newValue
                self:_notify(computedKey, newValue, oldValue)
            end
        end
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
    销毁对象，清理所有监听器
]]
function Observable:destroy()
    self._observers = {}
    self._properties = {}
    self._computed = {}
    self._dependencyMap = {}
    self._batchUpdate = false
    self._pendingComputed = {}
end

return Observable

