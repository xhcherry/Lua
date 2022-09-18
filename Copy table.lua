people = {}
people.sayhi = function(self)
    print("say hi:" .. self.name)
end
--function people.sayhi()
--    print("say hi")
--end
function copy(dist, tab)
    for i, v in pairs(table) do
        dist[i] = v
    end
end
function clone(tab)
    local ins = {}
    for i, v in pairs(tab) do
        ins[i] = v
    end
    return ins
end
people.new = function(name)
    local self = clone(people)
    self.name = name
    return self
end
--local p=clone(people)
--p.sayhi()
local p = people.new("zhang")
--p.sayhi(p)
--p:sayhi()
man = {}
man.new = function(name)
    local self = people.new(name)
    copy(self, man)
    return self
end
man.sayhello = function()
    print("man hello")
end
man.sayhi=function(self)
    print("man say hi "..self.name)
end
local m = man.new("li")
m:sayhi()