--[[
    数据绑定器 - 负责ViewModel和View之间的数据绑定
]]

-- 本地化全局函数
local pairs = pairs
local print = print

local Binder = class("Binder")

function Binder:ctor()
    -- 绑定的ViewModel
    self._viewModel = nil
    
    -- 数据绑定集合 {modelName = {propertyName = [{node, updateFunc, disposer}, ...]}}
    self._bindings = {}
end

--[[
    设置ViewModel
    @param viewModel ViewModel ViewModel实例
]]
function Binder:setViewModel(viewModel)
    if self._viewModel then
        self:unbindAll()
    end
    
    self._viewModel = viewModel
end

--[[
    获取ViewModel
    @return ViewModel
]]
function Binder:getViewModel()
    return self._viewModel
end

--[[
    绑定属性到UI组件
    @param modelName string Model名称
    @param propertyName string 属性名
    @param node cc.Node 节点
    @param updateFunc function 更新函数 function(node, newValue, oldValue)
    @return Binder 返回self以支持链式调用
]]
function Binder:bind(modelName, propertyName, node, updateFunc)
    if not self._viewModel then
        print("[Binder] 错误: 未设置ViewModel")
        return self
    end
    
    -- 获取Model
    local model = self._viewModel:getModel(modelName)
    if not model then
        return self
    end
    
    -- 保存绑定信息
    local modelBindings = self._bindings[modelName]
    if not modelBindings then
        modelBindings = {}
        self._bindings[modelName] = modelBindings
    end
    
    local propBindings = modelBindings[propertyName]
    if not propBindings then
        propBindings = {}
        modelBindings[propertyName] = propBindings
    end
    
    -- 创建回调包装函数
    local function callback(newValue, oldValue)
        updateFunc(node, newValue, oldValue)
    end
    
    -- 监听属性变化
    local disposer = model:observe(propertyName, callback)
    
    -- 保存绑定信息（包含disposer便于精确解绑）
    propBindings[#propBindings + 1] = {
        node = node,
        updateFunc = updateFunc,
        callback = callback,
        disposer = disposer
    }
    
    -- 立即更新一次
    local currentValue = model:get(propertyName)
    if currentValue ~= nil then
        updateFunc(node, currentValue, nil)
    end
    
    return self
end

--[[
    解除指定属性的绑定
    @param modelName string Model名称
    @param propertyName string 属性名
]]
function Binder:unbind(modelName, propertyName)
    local modelBindings = self._bindings[modelName]
    if not modelBindings then
        return
    end
    
    local propBindings = modelBindings[propertyName]
    if propBindings then
        -- 执行所有该属性的解绑函数
        for i = 1, #propBindings do
            propBindings[i].disposer()
        end
        modelBindings[propertyName] = nil
    end
end

--[[
    解除指定节点的绑定
    @param modelName string Model名称
    @param propertyName string 属性名
    @param node cc.Node 节点
]]
function Binder:unbindNode(modelName, propertyName, node)
    local modelBindings = self._bindings[modelName]
    if not modelBindings then
        return
    end
    
    local propBindings = modelBindings[propertyName]
    if not propBindings then
        return
    end
    
    for i = #propBindings, 1, -1 do
        if propBindings[i].node == node then
            propBindings[i].disposer()
            table.remove(propBindings, i)
        end
    end
end

--[[
    解除所有绑定
]]
function Binder:unbindAll()
    -- 遍历所有绑定并执行解绑
    for _, modelBindings in pairs(self._bindings) do
        for _, propBindings in pairs(modelBindings) do
            for i = 1, #propBindings do
                propBindings[i].disposer()
            end
        end
    end
    
    self._bindings = {}
end

--[[
    销毁绑定器
]]
function Binder:destroy()
    self:unbindAll()
    self._viewModel = nil
end

--[[
    对象池：重用时调用
]]
function Binder:onReuse()
    self._viewModel = nil
    self._bindings = {}
end

--[[
    对象池：回收时调用
]]
function Binder:onRecycle()
    self:unbindAll()
    self._viewModel = nil
end

--[[
    获取绑定数量
    @return number 绑定数量
]]
function Binder:getBindingCount()
    local count = 0
    for _, modelBindings in pairs(self._bindings) do
        for _, propBindings in pairs(modelBindings) do
            count = count + #propBindings
        end
    end
    return count
end

--[[
    检查是否已绑定某个属性
    @param modelName string Model名称
    @param propertyName string 属性名
    @return boolean
]]
function Binder:hasBinding(modelName, propertyName)
    local modelBindings = self._bindings[modelName]
    if not modelBindings then
        return false
    end
    local propBindings = modelBindings[propertyName]
    return propBindings ~= nil and #propBindings > 0
end

return Binder
