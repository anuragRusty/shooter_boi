PUMPKIN = {
    name = "enemy";
    weapon_type = "gun"; --add weapon obj
    x = 100;
    y = 100;
    width = TILE;
    height = 42;
    scale = 1;
    speed = 50;
    acceleration = 250;
    friction = 300;
    health = 200;
    anim_run_dur = 0.35;
    anim_stand_dur = 0.1;
    frames = '1-6';
    texture = love.graphics.newImage("assets/spritesheets/pumpkin_sheet.png");
 }

 BOWMAN = {
    name = "enemy";
    weapon_type = "bow"; --add weapon obj
    x = 100;
    y = 100;
    width = TILE;
    height = 42;
    scale = 1;
    speed = 50;
    acceleration = 250;
    friction = 300;
    health = 200;
    anim_run_dur = 0.1;
    anim_stand_dur = 0.2;
    frames = '1-6';
    texture = love.graphics.newImage("assets/spritesheets/bowman_sheet.png");
 }

local Enemy = Entity:new{};

function Enemy:new(config)
    local obj = Entity:new(config);
    setmetatable(obj,self);
    self.__index = self;
    return obj;
end

function Enemy:load()
    self:setRandomPosition();
    self:loadPhysics();
    self:loadAnimation();   
end

function Enemy:addSensors()
    
end

function Enemy:update(dt)
    self:SyncPhysics();
    self:ai(dt);
    self:move();
    self:animate(dt);
    self:tintingEffect(dt);
    self:animateDeath();
    self:spawnAnimation(dt)
end

function Enemy:ai(dt)
    if self.moving and self.state == 'alive' then
       self:applyAccelration(dt);
    else
       self:applyFriction(dt);
    end
    self.moving = not self.body:isTouching(Player.body);
end

function Enemy:SyncPhysics()
    local diffX,diffY = Player.x-self.x,Player.y-self.y;
    self.angle = math.atan2(diffY,diffX);
    self:syncPosition();
end

function Enemy:draw()
    self:drawSprite();
end

return Enemy;