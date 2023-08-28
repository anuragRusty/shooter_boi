local Weapon = {};

function Weapon:new()
    local obj = {};
    setmetatable(obj,self);
    self.__index = self;
    return obj;
end

function Weapon:syncPhysics()
    
end

return Weapon;