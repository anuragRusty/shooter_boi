BULLET_TEXTURE = love.graphics.newImage("assets/spritesheets/bullet_sheet.png");
ARROW_TEXTURE = love.graphics.newImage("assets/spritesheets/arrow_sheet.png");
BULLET_GRID = Anim8.newGrid(TILE/2,TILE/2, BULLET_TEXTURE:getWidth(), BULLET_TEXTURE:getHeight());
ARROW_GRID = Anim8.newGrid(TILE,11,ARROW_TEXTURE:getWidth(),ARROW_TEXTURE:getHeight());

local Bullet = {};

function Bullet:new(type,x,y,range,angle,speed,damage,scale)
    local obj = {
        x = x + math.cos(angle)*TILE/1.5;
        y = y + math.sin(angle)*TILE/1.5;
        damage = damage;
        range = range;
        angle = angle;
        radius = TILE/4*scale;
        scale = scale;
        color = WHITE;
        dx = 0;
        dy = 0;
        type = type;
        speed = speed;
        texture = type == "bullet" and BULLET_TEXTURE or ARROW_TEXTURE;
        animation = type == "bullet" and Anim8.newAnimation(BULLET_GRID("1-3",1),0.02) or Anim8.newAnimation(ARROW_GRID("1-3",1),0.3);
    };
    setmetatable(obj,self);
    self.__index = self;
    return obj;
end

function Bullet:load()
    self.shape = love.physics.newCircleShape(self.radius);
    self.body = love.physics.newBody(World, self.x, self.y, "dynamic");
    self.fixture = love.physics.newFixture(self.body, self.shape);
    self.body:setMass(1000);
    self.body:setBullet(true);
end

function Bullet:update(dt)
    self:go();
    self.animation:update(dt);
    self:collisions();
end

function Bullet:collisions()
    for _,enemy in pairs(Wave.enemies) do
        if self.body:isTouching(enemy.body) then
            self.body:setType("kinematic");
            self.body:setBullet(false);
            enemy.shoted = true;
            enemy.health = enemy.health - self.damage;
        end
    end

    if self.body:isTouching(Player.body) then
       Player.shoted = true;
    end
end

function Bullet:go()
    self.dx = math.cos(self.angle);
    self.dy = math.sin(self.angle);
    self.body:setLinearVelocity(self.speed * self.dx, self.speed * self.dy);
end

function Bullet:isExhausted()
    return math.sqrt((self.x - self.body:getX())^2 + (self.y - self.body:getY())^2) > self.range or not self.body:isBullet(); 
end

function Bullet:draw()
    love.graphics.setColor(self.color);
    love.graphics.push();
    love.graphics.translate(self.body:getX(),self.body:getY());
    love.graphics.rotate(self.angle);
    self.animation:draw(self.texture,-self.radius,-self.radius,0,self.scale,self.scale);
    love.graphics.pop();
end

function BulletBeginContact(fixture1,fixture2,contact)
    local body1 = fixture1:getBody();
    local body2 = fixture2:getBody();
    if body1:getType() == "static" and body2:isBullet() and contact:isTouching() then
        body2:setBullet(false);
    elseif body2:getType() == "static" and body1:isBullet() and contact:isTouching() then
        body1:setBullet(false);
    end
end

return Bullet;
