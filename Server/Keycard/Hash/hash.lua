local arg = {...}
local m = 6959

if arg[1] == nil then return end

local i = 0

for j = 1, #arg[1] do
    local t = string.byte(arg[1], j)
    i = i + t + j
end

local o = math.mod(i * (i + 3), m)

print(tostring(o))
