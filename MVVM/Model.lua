--[[
    Model基类 - 表示数据模型
]]

-- 本地化全局函数
local pairs = pairs

local Observable = require("MVVM.Observable")
local Model = class("Model", Observable)

function Model:ctor()
    Model.super.ctor(self)
    
    -- 模型名称
    self._modelName = ""
    
    -- 是否已初始化
    self._initialized = false
end

--[[
    初始化模型
    子类应该重写此方法来设置初始数据
]]
function Model:initialize()
    if self._initialized then
        return
    end
    
    self:onInitialize()
    self._initialized = true
end

--[[
    初始化回调，子类重写
]]
function Model:onInitialize()
    -- 子类实现
end

--[[
    设置模型名称
    @param name string 模型名称
]]
function Model:setModelName(name)
    self._modelName = name
end

--[[
    获取模型名称
    @return string 模型名称
]]
function Model:getModelName()
    return self._modelName
end

--[[
    验证模型数据
    @return boolean 是否验证通过
    @return string 错误信息
]]
function Model:validate()
    -- 子类实现
    return true, nil
end

--[[
    重置数据到初始状态
]]
function Model:reset()
    self._properties = {}
    self:onInitialize()
end

--[[
    导出数据为表格
    @return table 数据表格
]]
function Model:toTable()
    local result = {}
    for key, value in pairs(self._properties) do
        result[key] = value
    end
    return result
end

--[[
    从表格导入数据
    @param data table 数据表格
    @param silent boolean 是否静默导入
]]
function Model:fromTable(data, silent)
    self:setData(data, silent)
end

--[[
    克隆模型
    @return Model 新的模型实例
]]
function Model:clone()
    local newModel = self.class.new()
    newModel:fromTable(self:toTable(), true)
    return newModel
end

--[[
    保存数据（可以重写实现持久化）
    @return boolean 是否保存成功
]]
function Model:save()
    -- 子类可以重写实现持久化逻辑
    return true
end

--[[
    加载数据（可以重写实现持久化）
    @return boolean 是否加载成功
]]
function Model:load()
    -- 子类可以重写实现持久化逻辑
    return true
end

--[[
    销毁模型
]]
function Model:destroy()
    -- 调用父类销毁
    Model.super.destroy(self)
end

return Model

