--[[
    ModelConfig.lua

    配置说明：
    {
        name: Model名称（字符串）
        class: Model类
        description: 描述信息（可选）
    }
]]

local ModelName = {
    USER = "user",
}

return {
    models = {
        {
            name = ModelName.USER,
            class = nil,  -- UserModel,
            description = "用户数据",
        },
    },
}

