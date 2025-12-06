--[[
    UI管理器 - 负责界面的创建、显示、隐藏、销毁和层级管理
]]

local table_remove = table.remove

local ObjectPool = require("Frame.Pool.ObjectPool")

local UIManager = class("UIManager")

local _instance = nil

function UIManager:getInstance()
    if not _instance then
        _instance = UIManager.new()
    end
    return _instance
end

function UIManager:ctor()
    -- 当前显示的界面
    self._views = {}
    
    -- 界面栈
    self._viewStack = {}
    
    -- 界面配置
    self._viewConfigs = {}
    
    -- 根节点
    self._rootNode = nil

    -- 是否已初始化
    self._initialized = false
end

--[[
    初始化UI管理器
    @param rootNode cc.Node 根节点
]]
function UIManager:initialize(rootNode)
    if self._initialized then
        return
    end

    self._rootNode = rootNode
    self:loadConfig()
    self._initialized = true
end

--[[
    从配置文件加载并注册所有界面
    @return number 成功注册的界面数量
]]
function UIManager:loadConfig()
    local success, config = pcall(require, "Configs.UIConfig")
    if not success then
        print("[UIManager] 错误: 无法加载配置文件")
        return 0
    end
    
    if not config.views then
        print("[UIManager] 错误: 配置文件中没有views字段")
        return 0
    end
    
    local count = 0
    local views = config.views
    for i = 1, #views do
        local viewConfig = views[i]
        if viewConfig.viewClass then
            self._viewConfigs[viewConfig.id] = viewConfig
            count = count + 1
        end
    end
    
    return count
end

--[[
    显示界面
    @param uid number 界面ID
    @param params table 传递给界面的参数（可选）
    @return View 界面实例
]]
function UIManager:showView(uid, params)
    if not self._rootNode then
        print("[UIManager] 错误: 未初始化，请先调用initialize()")
        return nil
    end
    
    local config = self._viewConfigs[uid]
    if not config then
        print("[UIManager] 错误: 未注册的界面 '" .. uid .. "'")
        return nil
    end
    
    -- 如果已经显示，先关闭
    if self._views[uid] then
        self:closeView(uid)
    end
    
    -- 创建新的View和ViewModel
    local view = config.viewClass.new(config)
    local viewModel = nil
    
    if config.viewModelClass then
        viewModel = ObjectPool.acquire(config.viewModelClass)
        viewModel:setParams(params)
        viewModel:initialize()
    end
    
    -- 初始化View
    view:initialize()
    
    -- 绑定ViewModel，必须在View初始化之后
    if viewModel then
        view:setViewModel(viewModel)
    end
    
    -- 添加到场景
    local zOrder = config.zOrder or 0
    self._rootNode:addChild(view, zOrder)
    
    -- 保存引用
    self._views[uid] = view
    
    -- 添加到栈
    self._viewStack[#self._viewStack + 1] = uid
    
    return view
end

--[[
    关闭界面
    @param uid number 界面ID
]]
function UIManager:closeView(uid)
    local view = self._views[uid]
    if not view then
        return
    end
    
    -- 从父节点移除
    if view:getParent() then
        view:removeFromParent()
    end
    
    -- 移除引用
    self._views[uid] = nil
    
    -- 从栈中移除
    local viewStack = self._viewStack
    for i = #viewStack, 1, -1 do
        if viewStack[i] == uid then
            table_remove(viewStack, i)
            break
        end
    end
end

--[[
    关闭当前界面（栈顶）
]]
function UIManager:closeCurrentView()
    local viewStack = self._viewStack
    if #viewStack == 0 then
        return
    end
    
    local uid = viewStack[#viewStack]
    self:closeView(uid)
end

--[[
    关闭所有界面
]]
function UIManager:closeAllViews()
    while #self._viewStack > 0 do
        self:closeCurrentView()
    end
end

--[[
    获取界面实例
    @param uid number 界面ID
    @return View 界面实例（可能为nil）
]]
function UIManager:getView(uid)
    return self._views[uid]
end

--[[
    检查界面是否显示
    @param uid number 界面ID
    @return boolean
]]
function UIManager:isViewShowing(uid)
    return self._views[uid] ~= nil
end

--[[
    销毁UI管理器
]]
function UIManager:destroy()
    self:closeAllViews()
    self._views = {}
    self._viewStack = {}
    self._viewConfigs = {}
    self._rootNode = nil
    self._initialized = false
end

return UIManager
