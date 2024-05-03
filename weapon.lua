local Weapon = {};

function Weapon:new()
    local obj = {
        x = 0;
        y = 0;
        range = TILE;
        margin = TILE/2;
        width = TILE;
        height = TILE;
        angle = 0;
        triggered = false;
        sensor_solid = false;
        wall_collision = false;
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

function Weapon:loadSensor()
    self.shape = love.physics.newRectangleShape(self.range,self.height/2);
    self.body = love.physics.newBody(World,self.x,self.y,"dynamic");
    self.fixture = love.physics.newFixture(self.body,self.shape);
    self.fixture:setSensor(not self.sensor_solid);
end

function Weapon:updateSensor()
    self.body:setPosition(self.x + math.cos(self.angle)*self.range/2,self.y + math.sin(self.angle)*self.range/2);
    self.body:setAngle(self.angle);
    self.triggered = self.body:isTouching(Player.body) and (not self.wall_collision);
end

function Weapon:sensorBeginContact(fixture1,fixture2,contact)
    local body1 = fixture1:getBody();
    local body2 = fixture2:getBody();
    if self.body == body1 and body2:getType() == 'static' or self.body == body2 and body1:getType() == 'static' then
        self.wall_collision = true;
    end
end

function Weapon:sensorEndContact(fixture1,fixture2,contact)
    local body1 = fixture1:getBody();
    local body2 = fixture2:getBody();
    if self.body == body1 and body2:getType() == 'static' or self.body == body2 and body1:getType() == 'static' then 
        self.wall_collision = false;
    end
end

function Weapon:drawSensor()
    love.graphics.push();
    love.graphics.translate(self.body:getX(),self.body:getY());
    love.graphics.rotate(self.angle);
    love.graphics.rectangle("line",-self.range/2,-self.height/4,self.range,self.height/2);
    love.graphics.pop();
end

return Weapon;