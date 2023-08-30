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
    anim_run_dur = 0.2;
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
    self:loadWeapon();   
end

function Enemy:loadWeapon()
    self.weapon = Spear:new();
    self.weapon:load();
end

function Enemy:updateWeapon(dt)
    if self.state == 'alive' then
       self.weapon:update(dt,self.x,self.y,self.angle);
    end
end

function Enemy:drawWeapon()
    self.weapon:draw();
end

function Enemy:addSensors()
    
end

function Enemy:update(dt)
    self:updateWeapon(dt);
    self:SyncPhysics();
    self:ai(dt);
    self:move();
    self:animate(dt);
    self:tintingEffect(dt);
    self:animateDeath();
    self:spawnAnimation(dt);
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
    if self:isLeft() then
        self:drawWeapon();
        self:drawSprite();
    else 
        self:drawSprite();
        self:drawWeapon();
    end
    self:drawHealthBar(self.x-self.width/2,self.y+self.height/2,1/3);
end

return Enemy;