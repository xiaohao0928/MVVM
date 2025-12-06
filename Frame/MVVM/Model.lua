--[[
    Model基类 - 表示数据模型
]]

local Observable = require("Frame.MVVM.Observable")
local Model = class("Model", Observable)

function Model:ctor()
    Model.super.ctor(self)
    
    -- 模型名称
    self._modelName = ""
    
    -- 是否已初始化
    self._initialized = false
end

--[[
    初始化回调，子类重写
]]
function Model:onInitialize()
    -- 子类实现
end

--[[
    销毁回调，子类重写1
]]
function Model:onDestroy()
    -- 子类实现
end

--[[
    加载数据，子类重写
]]
function Model:loadData()
    -- 子类实现
end

--[[
    保存数据，子类重写
]]
function Model:saveData()
    -- 子类实现
end

--[[
    初始化模型
    子类应该重写此方法来设置初始数据
]]
function Model:initialize()
    if self._initialized then
        return
    end

    self:loadData()
    
    self:onInitialize()
    self._initialized = true
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
    销毁模型
]]
function Model:destroy()
    Model.super.destroy(self)
    self:saveData()
end

return Model
