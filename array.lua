arr={1,2,3,4,5,"sdf"}
for i, v in pairs(arr) do
   print(i,v)
end
print()
arr = {}
for i = 1, 100 do
    table.insert(arr, 1, i)
end
for i, v in pairs(arr) do
    print(i, v)
end
