--[[
    示例入口
    
    使用方法：
    local Example = require("Example.Main")
    Example.run(scene)
]]

-- 加载模块
require("MVVM.Init").load()
require("Manager.Init").load()

local ModelManager = require("Manager.ModelManager")
local UIManager = require("Manager.UIManager")
local UIConfig = require("Example.Configs.UIConfig")

local M = {}

function M.run(scene)
    -- 初始化ModelManager（需要临时替换配置路径）
    -- 注意：实际项目中应该修改ModelManager读取的配置路径
    local modelConfig = require("Example.Configs.ModelConfig")
    for i = 1, #modelConfig.models do
        local cfg = modelConfig.models[i]
        if cfg.class then
            local model = cfg.class.new()
            model:setModelName(cfg.id)
            model:initialize()
            ModelManager:getInstance()._models[cfg.id] = model
        end
    end
    
    -- 初始化UIManager（需要临时注册View配置）
    UIManager:getInstance()._rootNode = scene
    for i = 1, #UIConfig.views do
        local cfg = UIConfig.views[i]
        if cfg.viewClass then
            UIManager:getInstance()._viewConfigs[cfg.id] = cfg
        end
    end
    
    -- 显示主界面
    UIManager:getInstance():showView(UIConfig.UID.MAIN)
end

function M.stop()
    UIManager:getInstance():closeAllViews()
end

return M

