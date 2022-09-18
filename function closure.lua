function people(name)
    local self = {}
    local function init()
        self.name = name
    end

    self.sayhi = function()
        print("hello " .. self.name)
    end
    init()
    return self
end
--local p = people("zhangsan")
--p:sayhi()
function man(name)
    local self = people(name)
    --local function init() end
    self.sayhello = function()
        print("hi " .. self.name)
    end
    return self
end
local m = man("li")
m:sayhello()
m:sayhi()