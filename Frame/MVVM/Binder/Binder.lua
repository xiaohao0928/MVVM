--[[
    绑定器基类 - 提供通用的绑定管理功能
]]

local Binder = class("Binder")

function Binder:ctor()
    -- 实例ID，用于解决回调时对象可能已回收复用的问题
    self._instanceId = 0

    -- 绑定的ViewModel
    self._viewModel = nil
    
    -- 数据绑定集合 {propertyName = [{bindingInfo}, ...]}
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
    解除指定属性的绑定
    @param propertyName string 属性名
]]
function Binder:unbind(propertyName)
    local propBindings = self._bindings[propertyName]
    if propBindings then
        for i = 1, #propBindings do
            propBindings[i].disposer()
        end
        self._bindings[propertyName] = nil
    end
end

--[[
    解除所有绑定
]]
function Binder:unbindAll()
    local bindings = self._bindings
    self._bindings = {}
    
    for _, propBindings in pairs(bindings) do
        for i = 1, #propBindings do
            propBindings[i].disposer()
        end
    end
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
    self:destroy()
    self._instanceId = self._instanceId + 1
end

return Binder
