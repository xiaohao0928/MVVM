--[[
    ViewModel基类 - 管理业务逻辑和命令
    Model通过ModelManager获取
]]

-- 本地化全局函数
local print = print
local string_format = string.format

local ModelManager = require("Manager.ModelManager")

local ViewModel = class("ViewModel")

function ViewModel:ctor()
    -- 命令集合
    self._commands = {}
    
    -- 是否已初始化
    self._initialized = false
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
    初始化回调，子类重写
]]
function ViewModel:onInitialize()
    -- 子类实现
end

--[[
    获取Model（从ModelManager获取）
    @param name string Model名称
    @return Model Model实例
]]
function ViewModel:getModel(name)
    return ModelManager:getInstance():getModel(name)
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
        print(string_format("[ViewModel] 错误: 命令不存在 '%s'", name))
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

--[[
    销毁ViewModel
]]
function ViewModel:destroy()
    self._commands = {}
    self._initialized = false
end

--[[
    对象池：重用时调用
]]
function ViewModel:onReuse()
    self._commands = {}
    self._initialized = false
end

--[[
    对象池：回收时调用
]]
function ViewModel:onRecycle()
    self._commands = {}
    self._initialized = false
end

return ViewModel
