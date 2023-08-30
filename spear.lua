SPEAR_TEXTURE = love.graphics.newImage("assets/spritesheets/spear_sheet.png");
SPEAR_GRID = Anim8.newGrid(TILE*2,13,SPEAR_TEXTURE:getWidth(),SPEAR_TEXTURE:getHeight());

Spear = Weapon:new();

function Spear:new()
    local obj = {
        width = TILE*2;
        height = 13;
        animation = Anim8.newAnimation(SPEAR_GRID('1-3',1),0.10);
    };
    setmetatable(obj,self);
    self.__index = self;
    return obj;
end

function Spear:load()
    self:loadSensor();
end

function Spear:loadSensor()
    self.shape = love.physics.newRectangleShape(self.height/2,self.height/2);
    self.body = love.physics.newBody(World,self.x,self.y,"kinematic");
    self.fixture = love.physics.newFixture(self.body,self.shape);
    self.fixture:setSensor(true);
end

function Spear:updateSensor()
    self.body:setPosition(self.x + (math.cos(self.angle)*(self.width/2 - self.height/2)),self.y + (math.sin(self.angle)*(self.width/2 - self.height/2)));
end

function Spear:update(dt,x,y,angle)
    self:attack(dt);
    self:syncPhysics(x,y,angle);
    self:updateSensor();
end

function Spear:attack(dt)
    if self.triggered then
       self.animation:update(dt); 
    end
    local collison = self.body:isTouching(Player.body);
    self.triggered = collison;
    self.fixture:setSensor(not collison);
    
    if collison then
    Player.shoted = collison;
    end
end

function Spear:draw()
    self:drawTransfomation();
    self.animation:draw(SPEAR_TEXTURE,-self.width/2,-self.height/2,0,1,1/2);
    self:clearTransfomation();
end

return Spear;