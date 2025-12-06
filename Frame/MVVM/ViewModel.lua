--[[
    ViewModel基类 - 管理业务逻辑和命令
]]

local ObjectPool = require("Frame.ObjectPool.ObjectPool")
local ModelManager = require("Frame.Manager.ModelManager")
local Observable = require("Frame.MVVM.Observable")
local ModelBinder = require("Frame.MVVM.Binder.ModelBinder")

local ViewModel = class("ViewModel", Observable)

function ViewModel:ctor()
    ViewModel.super.ctor(self)
    
    -- 命令集合
    self._commands = {}
    
    -- 参数
    self._params = nil
    
    -- Model绑定器
    self._modelBinder = ObjectPool.acquire(ModelBinder)
    self._modelBinder:setViewModel(self)
    
    -- 是否已初始化
    self._initialized = false
end

--[[
    初始化回调，子类重写
]]
function ViewModel:onInitialize()
    -- 子类实现
end

--[[
    销毁回调，子类重写
]]
function ViewModel:onDestroy()
    -- 子类实现
end

--[[
    初始化ViewModel
]]
function ViewModel:initialize()
    if self._initialized then
        return
    end
    
    self:onInitialize()
    self._initialized = true
end

--[[
    销毁ViewModel
]]
function ViewModel:destroy()
    -- 调用子类销毁回调
    self:onDestroy()
    
    self._commands = {}
    self._params = nil
    if self._modelBinder then
        ObjectPool.release(self._modelBinder)
        self._modelBinder = nil
    end
    self._initialized = false
    -- 调用父类 destroy 清理 _properties 和 _observers
    ViewModel.super.destroy(self)
end

--[[
    对象池：重用时调用
]]
function ViewModel:onReuse()
    self._commands = {}
    self._params = nil
    self._modelBinder = ObjectPool.acquire(ModelBinder)
    self._modelBinder:setViewModel(self)
    self._initialized = false
end

--[[
    对象池：回收时调用
]]
function ViewModel:onRecycle()
    self:destroy()
end

--[[
    设置参数
    @param params table 参数
]]
function ViewModel:setParams(params)
    self._params = params
end

--[[
    获取参数
    @return table
]]
function ViewModel:getParams()
    return self._params
end

--[[
    获取Model
    @param name string Model名称
    @return Model Model实例
]]
function ViewModel:getModel(name)
    return ModelManager:getInstance():getModel(name)
end

--[[
    绑定Model属性到ViewModel属性
    @param modelName string Model名称
    @param modelProperty string Model属性名
    @param vmProperty string ViewModel属性名（可选，默认与Model属性同名）
    @return ViewModel 返回self以支持链式调用
]]
function ViewModel:bindModel(modelName, modelProperty, vmProperty)
    self._modelBinder:bindModel(modelName, modelProperty, vmProperty)
    return self
end

--[[
    获取ModelBinder
    @return ModelBinder
]]
function ViewModel:getModelBinder()
    return self._modelBinder
end

--[[
    注册命令
    @param name string 命令名称
    @param func function 命令函数
]]
function ViewModel:registerCommand(name, func)
    self._commands[name] = func
end

--[[
    执行命令
    @param name string 命令名称
    @param ... any 命令参数
    @return any 命令执行结果
]]
function ViewModel:executeCommand(name, ...)
    local command = self._commands[name]
    if not command then
        print("[ViewModel] 错误: 命令不存在 '" .. name .. "'")
        return nil
    end
    
    return command(self, ...)
end

--[[
    检查命令是否存在
    @param name string 命令名称
    @return boolean
]]
function ViewModel:hasCommand(name)
    return self._commands[name] ~= nil
end

return ViewModel
