--[[
print("hello")

function say()
    print("asd")
end
say()

function max(a, b)
    if a > b then
        return a
    else
        return b
    end
end
print(max(2, 3))

for i=1,100 do
    print(i)
end
--]]

--[[
Config = {h="hello"}
Config.word="hello"
Config.num="100"
Config["name"]="zhang"
print(Config["num"])
print(Config.word)

for i, v in pairs(Config) do
    print(i,v)
end
--]]

--arr={1,2,3,4,5,"sdf"}
--for i, v in pairs(arr) do
--   print(i,v)
--end

--[[arr = {}
for i = 1, 100 do
    table.insert(arr, 1, i)
end
for i, v in pairs(arr) do
    print(i, v)
end--]]



