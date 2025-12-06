--[[
    Model绑定器 - 负责ViewModel和Model之间的数据绑定
]]

local Binder = require("Frame.MVVM.Binder.Binder")

local ModelBinder = class("ModelBinder", Binder)

--[[
    绑定Model属性到ViewModel属性
    @param modelName string Model名称
    @param modelProperty string Model属性名
    @param vmProperty string ViewModel属性名（可选，默认与Model属性同名）
    @return ModelBinder 返回self以支持链式调用
]]
function ModelBinder:bindModel(modelName, modelProperty, vmProperty)
    local viewModel = self._viewModel
    if not viewModel then
        print("[ModelBinder] 错误: 未设置ViewModel")
        return self
    end
    
    -- 默认同名
    vmProperty = vmProperty or modelProperty
    
    -- 获取Model
    local model = viewModel:getModel(modelName)
    if not model then
        print("[ModelBinder] 错误: Model不存在 '" .. modelName .. "'")
        return self
    end
    
    -- 保存绑定信息
    local propBindings = self._bindings[vmProperty]
    if not propBindings then
        propBindings = {}
        self._bindings[vmProperty] = propBindings
    end
    
    -- 创建回调
    local binderId = self._instanceId
    local function callback(newValue, oldValue)
        if self._instanceId ~= binderId then
            return
        end
        viewModel:set(vmProperty, newValue)
    end
    
    -- 监听Model属性变化，同步到ViewModel
    local disposer = model:observe(modelProperty, callback)
    
    -- 保存绑定信息
    propBindings[#propBindings + 1] = {
        modelName = modelName,
        modelProperty = modelProperty,
        callback = callback,
        disposer = disposer
    }
    
    -- 立即同步一次
    local currentValue = model:get(modelProperty)
    if currentValue ~= nil then
        viewModel:set(vmProperty, currentValue)
    end
    
    return self
end

return ModelBinder
