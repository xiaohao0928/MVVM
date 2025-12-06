local M = {}

local modules = {
    "Frame.Pool.ObjectPool",
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