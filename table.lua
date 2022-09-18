Config = {h="hello"}
Config.word="hello"
Config.num="100"
Config["name"]="zhang"
print(Config["num"])
print(Config.word)
for i, v in pairs(Config) do
    print(i,v)
end

