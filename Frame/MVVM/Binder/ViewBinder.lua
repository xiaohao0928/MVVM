--[[
    View绑定器 - 负责View和ViewModel之间的数据绑定
]]

local Binder = require("Frame.MVVM.Binder.Binder")

local ViewBinder = class("ViewBinder", Binder)

--[[
    绑定ViewModel属性
    @param propertyName string 属性名
    @param updateFunc function 更新函数 function(newValue, oldValue)
    @return ViewBinder 返回self以支持链式调用
]]
function ViewBinder:bindVM(propertyName, updateFunc)
    local viewModel = self._viewModel
    if not viewModel then
        print("[ViewBinder] 错误: 未设置ViewModel")
        return self
    end
    
    -- 保存绑定信息
    local propBindings = self._bindings[propertyName]
    if not propBindings then
        propBindings = {}
        self._bindings[propertyName] = propBindings
    end
    
    -- 监听ViewModel属性变化
    local disposer = viewModel:observe(propertyName, updateFunc)
    
    -- 保存绑定信息
    propBindings[#propBindings + 1] = {
        updateFunc = updateFunc,
        disposer = disposer
    }
    
    -- 立即更新一次
    local currentValue = viewModel:get(propertyName)
    if currentValue ~= nil then
        updateFunc(currentValue, nil)
    end
    
    return self
end

--[[
    直接绑定Model属性
    @param modelName string Model名称
    @param propertyName string 属性名
    @param updateFunc function 更新函数 function(newValue, oldValue)
    @return ViewBinder 返回self以支持链式调用
]]
function ViewBinder:bindModel(modelName, propertyName, updateFunc)
    local viewModel = self._viewModel
    if not viewModel then
        print("[ViewBinder] 错误: 未设置ViewModel")
        return self
    end
    
    local model = viewModel:getModel(modelName)
    if not model then
        print("[ViewBinder] 错误: Model不存在 '" .. modelName .. "'")
        return self
    end
    
    -- 保存绑定信息（用 modelName.propertyName 作为 key）
    local bindKey = modelName .. "." .. propertyName
    local propBindings = self._bindings[bindKey]
    if not propBindings then
        propBindings = {}
        self._bindings[bindKey] = propBindings
    end
    
    -- 直接监听Model属性变化
    local disposer = model:observe(propertyName, updateFunc)
    
    -- 保存绑定信息
    propBindings[#propBindings + 1] = {
        updateFunc = updateFunc,
        disposer = disposer
    }
    
    -- 立即更新一次
    local currentValue = model:get(propertyName)
    if currentValue ~= nil then
        updateFunc(currentValue, nil)
    end
    
    return self
end

return ViewBinder
