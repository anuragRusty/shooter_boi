---PLAYER CONFIG
PLAYER = {
   name = "player";
   weapon_type = "guns";
   x = love.graphics.getWidth()/2;
   y = love.graphics.getHeight()/2;
   width = TILE;
   height = TILE;
   scale = 1;
   speed = 220;
   acceleration = 250;
   friction = 300;
   health = 1000;
   anim_run_dur = 0.1;
   anim_stand_dur = 0.5;
   frames = '1-6';
   texture = love.graphics.newImage("assets/spritesheets/player_sheet.png");
   guns = {Gun:new(PISTOL,false),Gun:new(SMG,false),Gun:new(AK47,false),Gun:new(SHOTGUN,false),Gun:new(SNIPER,false),Gun:new(BLASTER,false),Gun:new(BOW,false)};
}

Player = Entity:new(PLAYER);

function Player:load()
    self:loadPhysics();
    self:loadAnimation();
    self.gun_index = 1;
    self.gun = PLAYER.guns[#PLAYER.guns];
end

function Player:update(dt)
    self:SyncPhysics();
    self:go(dt);
    self:move();
    self.gun:update(dt,self.x,self.y,self.angle);
    self:animate(dt);
    self:tintingEffect(dt);
    self:gunZoom();
    self:animateDeath();
    self:spawnAnimation(dt)
end

function Player:gunZoom() --TEMP CHANGE
end

function Player:changeGun(x,y)
   self.gun_index = self.gun_index + 1;
   if y > 0 then
      if self.gun_index > #PLAYER.guns then
         self.gun_index = 1;
      end
   elseif y < 0 then
      self.gun_index = self.gun_index -1;
      if self.gun_index <= 0 then
         self.gun_index = #PLAYER.guns;
      end
   end
   self.gun = PLAYER.guns[self.gun_index];   
end

function Player:SyncPhysics()
    local mouseX, mouseY = love.mouse.getPosition()
    local diffX,diffY = mouseX-love.graphics.getWidth()/2,mouseY-love.graphics.getHeight()/2;
    self.angle = math.atan2(diffY,diffX);
    Player:syncPosition();
end

function Player:go(dt)
    if love.mouse.isDown(2) then
        self:applyAccelration(dt);
        self.moving = true;
    else
        self:applyFriction(dt);
        self.moving = false;
        self.gun.triggered = false;
    end

    if love.mouse.isDown(1) then
       self.gun.triggered = true;
    end

    if love.keyboard.isDown("space") then
        self.body:applyAngularImpulse()
    end
end

function Player:drawStatus()
    self:drawHealthBar(Camera.x + 3/2*TILE,Camera.y+TILE/2);
    self.animation_standing_right:draw(self.texture,Camera.x,Camera.y,0,3/2,3/2);
    self.gun:drawIcon();
end

function Player:draw()
 if self.angle < -math.pi/2 or self.angle > math.pi/2 then
    self.gun:draw();
    love.graphics.setColor(self.color);
    self:drawSprite();
 else
    love.graphics.setColor(self.color);
    self:drawSprite();
    self.gun:draw();
 end
end