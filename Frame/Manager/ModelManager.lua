--[[
    Model管理器 - 管理所有Model的创建、获取
]]

local ModelManager = class("ModelManager")

local _instance = nil

function ModelManager:getInstance()
    if not _instance then
        _instance = ModelManager.new()
    end
    return _instance
end

function ModelManager:ctor()
    -- Model实例
    self._models = {}

    -- 是否已初始化
    self._initialized = false
end

--[[
    初始化Model管理器
]]
function ModelManager:initialize()
    if self._initialized then
        return
    end
    
    self:loadConfig()
    self._initialized = true
end

--[[
    从配置文件加载并创建所有Model
    @return number 成功创建的Model数量
]]
function ModelManager:loadConfig()
    local success, config = pcall(require, "Configs.ModelConfig")
    if not success then
        print("[ModelManager] 错误: 无法加载配置文件")
        return 0
    end
    
    if not config.models then
        print("[ModelManager] 错误: 配置文件中没有models字段")
        return 0
    end
    
    local count = 0
    local models = config.models
    for i = 1, #models do
        local modelConfig = models[i]
        if modelConfig.class then
            local model = modelConfig.class.new()
            model:setModelName(modelConfig.name)
            model:initialize()
            self._models[modelConfig.name] = model
            count = count + 1
        end
    end
    
    return count
end

--[[
    获取Model实例
    @param modelName string Model名称
    @return Model Model实例
]]
function ModelManager:getModel(modelName)
    local model = self._models[modelName]
    if not model then
        print("[ModelManager] 错误: Model '" .. modelName .. "' 不存在")
    end
    return model
end

--[[
    检查Model是否存在
    @param modelName string Model名称
    @return boolean
]]
function ModelManager:hasModel(modelName)
    return self._models[modelName] ~= nil
end

--[[
    销毁所有Model
]]
function ModelManager:destroyAllModels()
    for _, model in pairs(self._models) do
        model:destroy()
    end
    self._models = {}
end

--[[
    销毁ModelManager
]]
function ModelManager:destroy()
    self:destroyAllModels()
    self._initialized = false
end

return ModelManager
