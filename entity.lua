HEALTH_TILE = love.graphics.newImage("assets/spritesheets/health_tile.png");
HEALTH_BORDER = love.graphics.newImage("assets/spritesheets/health_border.png");
MAX_HEALTH_BARS = HEALTH_BORDER:getWidth()/HEALTH_TILE:getWidth()-1;

local Entity = {};

function Entity:new(config)
    local obj = {
        name = config.name or "entity",
        state = 'spawn'; -- spawn alive dying dead;
        shoted = false;
        x = config.x or 100,
        y = config.y or 100,
        width = config.width or TILE,
        height = config.height or TILE,
        scale = config.scale or 1,
        moving = false,
        max_speed = config.speed or 0,
        speed = 0,
        acceleration = config.acceleration or 0,
        friction = config.friction or 0,
        health = config.health or 100,
        max_health = config.health or 100,
        angle = config.angle or 0,
        angle_dying = 0;
        dx = 0,
        dy = 0,
        color = WHITE,
        color_count = 1,
        tinting_time = 0,
        total_time = 0,
        anim_run_dur = config.anim_run_dur;
        anim_stand_dur = config.anim_stand_dur;
        frames = config.frames;
        texture = config.texture;
    }
    setmetatable(obj, self)
    self.__index = self
    return obj
end

function Entity:setRandomPosition()
   self.x = math.random(TILE*2,MAP_WIDTH-TILE);
   self.y = math.random(TILE*2,MAP_HEIGHT-TILE);
end

function Entity:loadPhysics()
    self.body = love.physics.newBody(World,self.x,self.y,"dynamic");
    self.shape = love.physics.newRectangleShape(self.width*self.scale,self.height*self.scale);
    self.fixture = love.physics.newFixture(self.body,self.shape);
    self.fixture:setUserData(self.name);
end

function Entity:move()
    self.body:setLinearVelocity(self.dx*self.speed,self.dy*self.speed);
end

function Entity:isLeft()
   return self.angle < -math.pi/2 or self.angle > math.pi/2;
 end

function Entity:syncPosition()
    self.dx = math.cos(self.angle);
    self.dy = math.sin(self.angle);
    self.x,self.y = self.body:getPosition();
end

function Entity:animateDeath()
   if self.health <= 0 then
      self.state = 'dying';
   end
   if self.state == 'dying' and math.abs(self.angle_dying) < math.pi/2 then
      self.angle_dying = self.angle_dying + 0.10 * (self:isLeft() and 1 or -1);
      self.shoted = true;
   end
   if math.abs(self.angle_dying) >= math.pi/2 then
      self.state = 'dead';
      self.moving = false;
      self.animation_standing_left:gotoFrame(3);
      self.animation_standing_right:gotoFrame(4);
   end
end

function Entity:spawnAnimation(dt)
  if self.state == 'spawn' then
     self.animation_spawn_left:update(dt);
     self.animation_spawn_right:update(dt);
   if self.animation_spawn_left.position >= 6 or self.animation_spawn_right.position >= 6 then
      self.state = 'alive';
   end
 end
end

function Entity:tintingEffect(dt)
    if self.shoted then
       local colors = {RED,WHITE};     
       if self.tinting_time > 0.15 then
          self.color = colors[self.color_count];
          self.tinting_time = 0;
          self.color_count = self.color_count + 1;
          if self.color_count > #colors then
             self.color_count = 1;
          end
      elseif self.total_time > 1.5 then
          self.shoted = false;
          self.color = WHITE;
          self.total_time = 0;
          self.tinting_time = 0;
      end
      self.total_time = self.total_time + dt;
      self.tinting_time = self.tinting_time + dt;
    end
end

function Entity:applyAccelration(dt)
    if self.speed < self.max_speed then
        if self.speed + self.speed*dt < self.max_speed then
           self.speed = self.speed + self.acceleration *dt;
        else
           self.speed = self.max_speed;
        end
    end
end

function Entity:applyFriction(dt)
    if self.speed > 0 then
       if self.speed - self.friction *dt > 0 then
          self.speed = self.speed - self.friction*dt;
       else
          self.speed = 0;
       end 
    end
end

function Entity:loadAnimation()
    self.grid = Anim8.newGrid(self.width,self.height,self.texture:getWidth(),self.texture:getHeight());
    self.animation_running_right = Anim8.newAnimation(self.grid(self.frames, 1), self.anim_run_dur);
    self.animation_standing_right = Anim8.newAnimation(self.grid(self.frames, 2), self.anim_stand_dur);
    self.animation_running_left = Anim8.newAnimation(self.grid(self.frames, 3), self.anim_run_dur);
    self.animation_standing_left = Anim8.newAnimation(self.grid(self.frames, 4), self.anim_stand_dur);
    self.animation_spawn_left = Anim8.newAnimation(self.grid(self.frames,6),self.anim_run_dur);
    self.animation_spawn_right = Anim8.newAnimation(self.grid(self.frames,5),self.anim_run_dur);
end

function Entity:animate(dt)
   if self.state == "alive" then
    self.animation_running_left:update(dt);
    self.animation_running_right:update(dt);
    self.animation_standing_left:update(dt);
    self.animation_standing_right:update(dt);
   end
end

function Entity:drawHealthBar(x,y,scale)
    local health_ratio = self.health/self.max_health;
    local bars = MAX_HEALTH_BARS*health_ratio;
    for i = 0,bars,1 do
    love.graphics.draw(HEALTH_TILE,x + (i*HEALTH_TILE:getWidth()*scale),y,0,scale,scale);
    end
    love.graphics.draw(HEALTH_BORDER,x,y,0,scale,scale);
end

function Entity:drawSprite()
    love.graphics.setColor(self.color);
    love.graphics.push();
    love.graphics.translate(self.x,self.y);
    love.graphics.rotate(self.angle_dying);
    if self.moving and self.state == 'alive' then
        if self:isLeft() then
           self.animation_running_left:draw(self.texture, -self.width/2*self.scale, -self.height/2*self.scale,0,self.scale,self.scale);
        else
           self.animation_running_right:draw(self.texture, -self.width/2*self.scale, -self.height/2*self.scale,0,self.scale,self.scale);
        end
     elseif self.state == 'alive' or self.state == 'dying' or self.state == 'dead' then
        if self:isLeft() then
            self.animation_standing_left:draw(self.texture, -self.width/2*self.scale, -self.height/2*self.scale,0,self.scale,self.scale);
         else
            self.animation_standing_right:draw(self.texture, -self.width/2*self.scale, -self.height/2*self.scale,0,self.scale,self.scale);
         end
      elseif self.state == 'spawn' then
         if self:isLeft() then
            self.animation_spawn_left:draw(self.texture, -self.width/2*self.scale, -self.height/2*self.scale,0,self.scale,self.scale);
         else
            self.animation_spawn_right:draw(self.texture, -self.width/2*self.scale, -self.height/2*self.scale,0,self.scale,self.scale);
         end
       end
     love.graphics.pop();
     love.graphics.setColor(WHITE);
end

return Entity;