--[[
    对象池 - 复用频繁创建销毁的对象
]]

local ObjectPool = {}

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
function ObjectPool.acquire(class, ...)
    local className = class.__cname
    if not className then
        -- 没有 __cname 的类不支持对象池，直接创建新对象
        return class.new(...)
    end
    
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
    
    -- 保存类名用于 release 时查找池
    obj._poolClassName = className
    obj._pooled = true
    return obj
end

--[[
    归还对象到池中
    @param obj object 对象实例
]]
function ObjectPool.release(obj)
    if not obj._pooled then
        return
    end
    
    local className = obj._poolClassName
    if not className then
        -- 没有类名信息，无法归还到池中
        obj._pooled = false
        return
    end
    
    -- 标记为已回收，防止重复 release
    obj._pooled = false
    
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
function ObjectPool.preload(class, count)
    local className = class.__cname
    if not className then
        -- 没有 __cname 的类不支持对象池
        return
    end
    
    local pool = getPool(className)
    
    for i = 1, count do
        local obj = class.new()
        -- 保存类名用于 release 时查找池
        obj._poolClassName = className
        -- 池中的对象标记为未被使用，acquire 时才设为 true
        obj._pooled = false
        pool.count = pool.count + 1
        pool.objects[pool.count] = obj
    end
end

--[[
    清空指定类的对象池
    @param class table 类
]]
function ObjectPool.clear(class)
    local className = class.__cname
    if className then
        _pools[className] = nil
    end
end

--[[
    清空所有对象池
]]
function ObjectPool.clearAll()
    _pools = {}
end

return ObjectPool

