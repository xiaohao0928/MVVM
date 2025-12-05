--[[
    对象池 - 复用频繁创建销毁的对象
]]

local Pool = {}

-- 各类对象的池
local _pools = {}

--[[
    获取对象池
    @param className string 类名
    @return table 对象池
]]
local function getPool(className)
    if not _pools[className] then
        _pools[className] = {
            objects = {},
            count = 0
        }
    end
    return _pools[className]
end

--[[
    从池中获取对象
    @param class table 类
    @param ... any 构造参数
    @return object 对象实例
]]
function Pool.get(class, ...)
    local className = class.__cname
    local pool = getPool(className)
    
    local obj
    if pool.count > 0 then
        -- 从池中取出
        obj = pool.objects[pool.count]
        pool.objects[pool.count] = nil
        pool.count = pool.count - 1
        
        -- 重新初始化
        if obj.onReuse then
            obj:onReuse(...)
        end
    else
        -- 创建新对象
        obj = class.new(...)
    end
    
    obj._pooled = true
    return obj
end

--[[
    归还对象到池中
    @param obj object 对象实例
]]
function Pool.release(obj)
    if not obj._pooled then
        return
    end
    
    local className = obj.class.__cname
    local pool = getPool(className)
    
    -- 重置对象状态
    if obj.onRecycle then
        obj:onRecycle()
    end
    
    -- 放回池中
    pool.count = pool.count + 1
    pool.objects[pool.count] = obj
end

--[[
    预创建对象
    @param class table 类
    @param count number 数量
]]
function Pool.preload(class, count)
    local className = class.__cname
    local pool = getPool(className)
    
    for i = 1, count do
        local obj = class.new()
        obj._pooled = true
        pool.count = pool.count + 1
        pool.objects[pool.count] = obj
    end
end

--[[
    清空指定类的对象池
    @param class table 类
]]
function Pool.clear(class)
    local className = class.__cname
    _pools[className] = nil
end

--[[
    清空所有对象池
]]
function Pool.clearAll()
    _pools = {}
end

--[[
    获取池中对象数量
    @param class table 类
    @return number 数量
]]
function Pool.getCount(class)
    local className = class.__cname
    local pool = _pools[className]
    return pool and pool.count or 0
end

return Pool

