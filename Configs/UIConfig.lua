--[[
    UIConfig.lua
    配置说明：
    {
        id: 界面ID
        name: 界面名称
        description:
        csb: csb文件路径
        zOrder: 层级
        viewClass: View类
        viewModelClass: ViewModel类
    }
]]

local UID = {
    MAIN = 1,
}

return {
    UID = UID,
    views = {
        {
            id = UID.MAIN,
            name = "主界面",
            description = "主界面",
            csb = "res/MainView.csb",
            zOrder = 0,
            viewClass = nil,
            viewModelClass = nil,
        },
    },
}
