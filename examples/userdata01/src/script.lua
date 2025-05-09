a = array.new(1000)
print("[Lua] Created userdata:", a) --> userdata: 0x8064d48
print("[Lua] Array size: " .. array.size(a)) --> 1000
for i = 1, 1000 do
  array.set(a, i, 1 / i)
end
print("[Lua] a[10] = " .. array.get(a, 10)) --> 0.1
