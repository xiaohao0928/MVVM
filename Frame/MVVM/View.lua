--[[
    View基类 - 管理视图和ViewModel的绑定
]]

local ViewBinder = require("Frame.MVVM.Binder.ViewBinder")
local ObjectPool = require("Frame.ObjectPool.ObjectPool")

local View = class("View", function()
    return cc.Node:create()
end)

function View:ctor(config)
    -- 配置
    self._config = config
    
    -- 数据绑定器
    self._binder = ObjectPool.acquire(ViewBinder)
    
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
    销毁回调，子类重写
]]
function View:onDestroy()
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
    self:loadCsb()

    -- 适配
    local winSize = cc.Director:getInstance():getWinSize()

    self.m_center = self:getChild("Node_Center")
    if not self.m_center then
        self.m_center = cc.Node:create()
        self:addChild(self.m_center)
    end
    self.m_center:setPosition(winSize.width / 2, winSize.height / 2)

    self.m_left = self:getChild("Node_Left")
    if not self.m_left then
        self.m_left = cc.Node:create()
        self:addChild(self.m_left)
    end
    self.m_left:setPosition(0, winSize.height / 2)

    self.m_right = self:getChild("Node_Right")
    if not self.m_right then
        self.m_right = cc.Node:create()
        self:addChild(self.m_right)
    end
    self.m_right:setPosition(winSize.width, winSize.height / 2)

    self.m_top = self:getChild("Node_Top")
    if not self.m_top then
        self.m_top = cc.Node:create()
        self:addChild(self.m_top)
    end
    self.m_top:setPosition(winSize.width / 2, winSize.height)

    self.m_bottom = self:getChild("Node_Bottom")
    if not self.m_bottom then
        self.m_bottom = cc.Node:create()
        self:addChild(self.m_bottom)
    end
    self.m_bottom:setPosition(winSize.width / 2, 0)
    
    self:onInitialize()
    self._initialized = true
end

--[[
    销毁视图
]]
function View:destroy()
    -- 调用子类销毁回调
    self:onDestroy()
    
    -- 清除子节点缓存
    self._childCache = {}
    
    -- 归还 ViewModel 到对象池
    if self._binder then
        local viewModel = self._binder:getViewModel()
        if viewModel then
            ObjectPool.release(viewModel)
        end
        
        -- 归还 ViewBinder 到对象池
        ObjectPool.release(self._binder)
        self._binder = nil
    end
    
    -- 清理其他引用
    self._config = nil
    self._csbNode = nil
    self._initialized = false
end

--[[
    节点移除时自动清理
]]
function View:onExit()
    self:destroy()
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
    获取ViewModel
    @return ViewModel
]]
function View:getViewModel()
    return self._binder:getViewModel()
end

--[[
    执行命令
    @param commandName string 命令名称
    @param ... any 命令参数
    @return any 命令执行结果
]]
function View:executeCommand(commandName, ...)
    local vm = self._binder:getViewModel()
    if vm then
        return vm:executeCommand(commandName, ...)
    end
    return nil
end

--[[
    绑定ViewModel属性
    @param propertyName string 属性名
    @param updateFunc function 更新函数 function(newValue, oldValue)
    @return View 返回self以支持链式调用
]]
function View:bindVM(propertyName, updateFunc)
    self._binder:bindVM(propertyName, updateFunc)
    return self
end

--[[
    直接绑定Model属性（绕过ViewModel，性能更高）
    @param modelName string Model名称
    @param propertyName string 属性名
    @param updateFunc function 更新函数 function(newValue, oldValue)
    @return View 返回self以支持链式调用
]]
function View:bindModel(modelName, propertyName, updateFunc)
    self._binder:bindModel(modelName, propertyName, updateFunc)
    return self
end

--[[
    解除所有绑定
]]
function View:unbindAll()
    self._binder:unbindAll()
end

--[[
    获取绑定器
    @return ViewBinder
]]
function View:getBinder()
    return self._binder
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
    获取csb根节点
    @return cc.Node
]]
function View:getCsbNode()
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
    local child = self:_findChild(self, name)
    
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
function View:_findChild(node, name)
    local child = node:getChildByName(name)
    if child then
        return child
    end
    
    local children = node:getChildren()
    for i = 1, #children do
        local found = self:_findChild(children[i], name)
        if found then
            return found
        end
    end
    
    return nil
end

return View

