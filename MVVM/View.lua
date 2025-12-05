--[[
    View基类 - 管理视图和ViewModel的绑定
]]

local Binder = require("MVVM.Binder")
local Pool = require("MVVM.Pool")

local View = class("View", function()
    return cc.Node:create()
end)

function View:ctor(config, params)
    -- 配置
    self._config = config
    
    -- 参数
    self._params = params
    
    -- 数据绑定器（从对象池获取）
    self._binder = Pool.get(Binder)
    
    -- csb根节点
    self._csbNode = nil
    
    -- 子节点缓存
    self._childCache = {}
    
    -- 是否已初始化
    self._initialized = false
end

--[[
    初始化回调，子类重写，这里创建ui
]]
function View:onInitialize()
    -- 子类实现
end

--[[
    绑定回调，子类重写，这里绑定数据流
]]
function View:onBindViewModel()
    -- 子类实现
end

--[[
    初始化视图
]]
function View:initialize()
    if self._initialized then
        return
    end
    
    -- 自动加载csb
    if self._config and self._config.csb then
        self:loadCsb()
    end
    
    self:onInitialize()
    self._initialized = true
end

--[[
    加载csb文件
    @return cc.Node csb根节点
]]
function View:loadCsb()
    if not self._config or not self._config.csb then
        return nil
    end
    self._csbNode = cc.CSLoader:createNode(self._config.csb)
    if self._csbNode then
        self:addChild(self._csbNode)
    end
    return self._csbNode
end

--[[
    获取配置
    @return table
]]
function View:getConfig()
    return self._config
end

--[[
    获取参数
    @return table
]]
function View:getParams()
    return self._params
end

--[[
    获取ViewModel
    @return ViewModel
]]
function View:getViewModel()
    return self._binder:getViewModel()
end

--[[
    获取绑定器
    @return Binder
]]
function View:getBinder()
    return self._binder
end

--[[
    获取csb根节点
    @return cc.Node
]]
function View:getCsbNode()
    return self._csbNode
end

--[[
    获取csb中的子节点
    @param name string 节点名称
    @return cc.Node
]]
function View:getChild(name)
    -- 先从缓存获取
    local cached = self._childCache[name]
    if cached then
        return cached
    end
    
    -- 递归查找
    local child = self:findChild(self, name)
    
    -- 缓存结果
    if child then
        self._childCache[name] = child
    end
    
    return child
end

--[[
    递归查找子节点
    @param node cc.Node 父节点
    @param name string 节点名称
    @return cc.Node
]]
function View:findChild(node, name)
    local child = node:getChildByName(name)
    if child then
        return child
    end
    
    local children = node:getChildren()
    for i = 1, #children do
        local found = self:findChild(children[i], name)
        if found then
            return found
        end
    end
    
    return nil
end

--[[
    清除子节点缓存
]]
function View:clearChildCache()
    self._childCache = {}
end

--[[
    设置ViewModel
    @param viewModel ViewModel ViewModel实例
]]
function View:setViewModel(viewModel)
    -- 设置绑定器的ViewModel
    self._binder:setViewModel(viewModel)
    
    -- 初始化ViewModel
    local vm = self._binder:getViewModel()
    if vm and not vm._initialized then
        vm:initialize()
    end
    
    -- 重新绑定
    if vm then
        self:onBindViewModel()
    end
end

--[[
    绑定属性到UI组件
    @param modelName string Model名称
    @param propertyName string 属性名
    @param node cc.Node 节点
    @param updateFunc function 更新函数 function(node, newValue, oldValue)
    @return View 返回self以支持链式调用
]]
function View:bind(modelName, propertyName, node, updateFunc)
    self._binder:bind(modelName, propertyName, node, updateFunc)
    return self
end

--[[
    解除所有绑定
]]
function View:unbindAll()
    self._binder:unbindAll()
end

--[[
    清理视图
]]
function View:onCleanup()
    -- 清除子节点缓存
    self._childCache = {}
    
    -- 归还 ViewModel 到对象池
    if self._binder then
        local viewModel = self._binder:getViewModel()
        if viewModel then
            Pool.release(viewModel)
        end
        
        -- 归还 Binder 到对象池
        Pool.release(self._binder)
        self._binder = nil
    end
end

--[[
    节点移除时自动清理
]]
function View:onExit()
    self:onCleanup()
end

return View

