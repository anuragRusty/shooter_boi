local Weapon = {};

function Weapon:new()
    local obj = {
        x = 0;
        y = 0;
        margin = TILE/2;
        width = TILE;
        height = TILE;
        angle = 0;
        triggered = false;
        color = WHITE;
    };
    setmetatable(obj,self);
    self.__index = self;
    return obj;
end

function Weapon:syncPhysics(x,y,angle)
    self.x,self.y = x + self.margin*math.cos(angle),y + self.margin*math.sin(angle);
    self.angle = angle;
end

function Weapon:isLeft()
  return self.angle < -math.pi/2 or self.angle > math.pi/2;
end

function Weapon:drawTransfomation()
    love.graphics.setColor(self.color);
    love.graphics.push();
    love.graphics.translate(self.x,self.y);
    love.graphics.rotate(self.angle);
end

function Weapon:clearTransfomation()
    love.graphics.pop();
end

return Weapon;