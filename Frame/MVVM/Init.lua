--[[
    MVVM模块加载和卸载
]]

-- 获取基础路径
local BASE = "Frame.MVVM"

local M = {}

local modules = {
    "Observable",
    "Model",
    "ViewModel",
    "View",
    "Binder.Binder",
    "Binder.ViewBinder",
    "Binder.ModelBinder",
}

function M.load()
    for i = 1, #modules do
        require(BASE .. "." .. modules[i])
    end
end

function M.unload()
    for i = 1, #modules do
        package.loaded[BASE .. "." .. modules[i]] = nil
    end
end

return M
