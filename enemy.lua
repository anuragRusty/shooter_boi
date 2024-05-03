PUMPKIN = {
    name = "enemy";
    weapon_type = 'spear'; --add weapon obj
    x = 100;
    y = 100;
    width = TILE;
    height = 42;
    scale = 1;
    speed = 100;
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
    weapon_type = 'bow'; --add weapon obj
    x = 100;
    y = 100;
    width = TILE;
    height = 42;
    scale = 1;
    speed = 50;
    acceleration = 250;
    friction = 300;
    health = 200;
    anim_run_dur = 0.07;
    anim_stand_dur = 0.2;
    frames = '1-6';
    texture = love.graphics.newImage("assets/spritesheets/bowman_sheet.png");
 }

local Enemy = Entity:new{};

function Enemy:new(config)
    local obj = Entity:new(config);
    obj.weapon_type = config.weapon_type;
    setmetatable(obj,self);
    self.__index = self;
    return obj;
end

function Enemy:load()
    self:setRandomPosition();
    self:loadPhysics();
    self:loadAnimation();
    self:loadWeapon();
    self:loadSensors();   
end

function Enemy:loadWeapon()
    if self.weapon_type == 'spear' then
       self.weapon = Spear:new();
    elseif self.weapon_type == 'bow' then
       self.weapon = Gun:new(BOW,true);
   end
   self.weapon:loadSensor();
end

function Enemy:updateWeapon(dt)
    if self.state == 'alive' then
       self.weapon:update(dt,self.x,self.y,self.angle);
        self.weapon:updateSensor();
        self:updateSensors();
    end
end

function Enemy:drawWeapon()
    self.weapon:draw();
    self.weapon:drawSensor();
end

function Enemy:loadSensors()
    self.left_body = love.physics.newBody(World,self.x - TILE,self.y,"dynamic");
    self.left_shape = love.physics.newRectangleShape(TILE,TILE);
    self.left_fixture = love.physics.newFixture(self.left_body,self.left_shape);
    self.left_fixture:setUserData(false);
    self.left_fixture:setSensor(true);
    self.right_body = love.physics.newBody(World,self.x + TILE,self.y,"dynamic");
    self.right_shape = love.physics.newRectangleShape(TILE,TILE);
    self.right_fixture = love.physics.newFixture(self.right_body,self.right_shape);
    self.right_fixture:setUserData(false);
    self.right_fixture:setSensor(true);
    self.top_body = love.physics.newBody(World,self.x,self.y-TILE,"dynamic");
    self.top_shape = love.physics.newRectangleShape(TILE,TILE);
    self.top_fixture = love.physics.newFixture(self.top_body,self.top_shape);
    self.top_fixture:setUserData(false);
    self.top_fixture:setSensor(true);
    self.down_body = love.physics.newBody(World,self.x,self.y+TILE,"dynamic");
    self.down_shape = love.physics.newRectangleShape(TILE,TILE);
    self.down_fixture = love.physics.newFixture(self.down_body,self.down_shape);
    self.down_fixture:setUserData(false);
    self.down_fixture:setSensor(true);
end

function Enemy:sensorBeginContact(fixture,fixture1,fixture2)
    local body1 = fixture1:getBody();
    local body2 = fixture2:getBody();
    if fixture == fixture1 and body2:getType() == "static" or  fixture == fixture2 and body1:getType() == "static" then
       fixture:setUserData(true);
    end
end

function Enemy:sensorEndContact(fixture,fixture1,fixture2)
    local body1 = fixture1:getBody();
    local body2 = fixture2:getBody();
    if fixture == fixture1 and body2:getType() == "static" or  fixture == fixture2 and body1:getType() == "static" then
        fixture:setUserData(false);
     end
end

function Enemy:updateSensors()
    self.left_body:setPosition(self.x - TILE/2,self.y);
    self.right_body:setPosition(self.x + TILE/2,self.y);
    self.top_body:setPosition(self.x,self.y-TILE/2);
    self.down_body:setPosition(self.x,self.y+TILE/2);
end

function Enemy:drawSensor(body,w,h)
    love.graphics.push();
    love.graphics.translate(body:getX(),body:getY());
    love.graphics.rectangle("line",-w/2,-h/2,w,h);
    love.graphics.pop();
end

function Enemy:beginContact(fixture1,fixture2,contact)
    self.weapon:sensorBeginContact(fixture1,fixture2,contact);
    self:sensorBeginContact(self.left_fixture,fixture1,fixture2);
    self:sensorBeginContact(self.right_fixture,fixture1,fixture2);
    self:sensorBeginContact(self.top_fixture,fixture1,fixture2);
    self:sensorBeginContact(self.down_fixture,fixture1,fixture2);
end

function Enemy:endContact(fixture1,fixture2,contact)
    self.weapon:sensorEndContact(fixture1,fixture2,contact);
    self:sensorEndContact(self.left_fixture,fixture1,fixture2);
    self:sensorEndContact(self.right_fixture,fixture1,fixture2);
    self:sensorEndContact(self.top_fixture,fixture1,fixture2);
    self:sensorEndContact(self.down_fixture,fixture1,fixture2);
end

function Enemy:update(dt)
    self:updateWeapon(dt);
    self:syncPosition();
    self:ai(dt);
    self:move();
    self:animate(dt);
    self:tintingEffect(dt);
    self:animateDeath();
    self:spawnAnimation(dt);
end

function Enemy:evalAngle(left, right, top, down)
    local diffX, diffY = Player.x - self.x, Player.y - self.y;
    local target_angle = math.atan2(diffY, diffX);
    local best_angle = target_angle;
    -- USE DEGREE FOR CONVIENCE AND BETTER EVALUATION BECUASE RADIAN SUCKS;
    
    if left then
        best_angle = best_angle + math.rad(45);
    elseif right then
        best_angle = best_angle - math.rad(45);
    elseif top then
        best_angle = best_angle + math.rad(45);
    elseif down then
        best_angle = best_angle - math.rad(45);
    end
    return best_angle;
end

function Enemy:ai(dt)
    local left,right,top,down = self.left_fixture:getUserData() , self.right_fixture:getUserData() ,self.top_fixture:getUserData() , self.down_fixture:getUserData();
    if self.state == "alive" then
       self.angle = self:evalAngle(left,right,top,down);
    end

    if self.moving and self.state == 'alive' then
       self:applyAccelration(dt);
    else
       self:applyFriction(dt);
    end
    self.moving = not self.body:isTouching(Player.body) and not self.weapon.triggered;
end

function Enemy:draw()
    --self:drawSensor(self.left_body,TILE/2,TILE);
    --self:drawSensor(self.right_body,TILE/2,TILE);
    --self:drawSensor(self.top_body,TILE,TILE/2);
    --self:drawSensor(self.down_body,TILE,TILE/2);
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