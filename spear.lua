SPEAR_TEXTURE = love.graphics.newImage("assets/spritesheets/spear_sheet.png");
SPEAR_GRID = Anim8.newGrid(TILE*2,13,SPEAR_TEXTURE:getWidth(),SPEAR_TEXTURE:getHeight());

Spear = Weapon:new();

function Spear:new()
    local obj = {
        width = TILE*2;
        range = TILE;
        height = 13;
        animation = Anim8.newAnimation(SPEAR_GRID('1-3',1),0.10);
        sensor_solid = true;
    };
    setmetatable(obj,self);
    self.__index = self;
    return obj;
end

function Spear:update(dt,x,y,angle)
    self:attack(dt);
    self:syncPhysics(x,y,angle);
end

function Spear:attack(dt)
    if self.triggered then
       self.animation:update(dt); 
    end
    local collison = self.body:isTouching(Player.body);
    self.triggered = collison;
    
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