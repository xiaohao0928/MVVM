--[[
    MVVM模块加载和卸载
]]

local M = {}

local modules = {
    "Frame.MVVM.Observable",
    "Frame.MVVM.Model",
    "Frame.MVVM.ViewModel",
    "Frame.MVVM.View",
    "Frame.MVVM.Binder.Binder",
    "Frame.MVVM.Binder.ViewBinder",
    "Frame.MVVM.Binder.ModelBinder",
}

function M.load()
    for i = 1, #modules do
        require(modules[i])
    end
end

function M.unload()
    for i = 1, #modules do
        package.loaded[modules[i]] = nil
    end
end

return M
