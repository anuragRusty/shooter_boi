GUN_FRAMES = 6;
--- GUNS CONFIGS CONST
PISTOL = {
    name = "pistol";
    firing_rate = 4;
    shell_cap = 1;
    mag_cap = 120;
    bullet_speed = 900;
    damage = 80;
    zoom = 2;
    range = (love.graphics.getWidth()/4 + love.graphics.getHeight()/4)/2;
    animation_time = 0.05;
    bullet_type = "bullet";
    bullet_scale = 1/4;
    width = TILE;
    height = TILE/2;
    margin = TILE/2;
    gun_texture = love.graphics.newImage("assets/spritesheets/pistol_sheet.png"); --NoT ADDED
    gun_sound = love.audio.newSource("assets/sounds/pistol.mp3","stream");
    grid = Anim8.newGrid(TILE,TILE/2,TILE*GUN_FRAMES, TILE);
};

SHOTGUN = {
    name = "shotgun";
    firing_rate = 0.5;
    shell_cap = 5;
    mag_cap = 7;
    bullet_speed = 2000;
    damage = 90;
    zoom = 2;
    range = (love.graphics.getWidth()/7 + love.graphics.getHeight()/7)/2;
    animation_time = 0.22;
    bullet_type = "bullet";
    bullet_scale = 1/3;
    width = TILE;
    height = TILE/2;
    margin = TILE/2;
    gun_texture = love.graphics.newImage("assets/spritesheets/shotgun_sheet.png");
    gun_sound = love.audio.newSource("assets/sounds/shotgun.mp3","stream");
    grid = Anim8.newGrid(TILE,TILE/2,TILE*GUN_FRAMES, TILE);
};

AK47 = {
    name = "ak47";
    firing_rate = 10;
    shell_cap = 1;
    mag_cap = 30;
    bullet_speed = 700;
    damage = 50;
    zoom = 1.8;
    range = (love.graphics.getWidth()/4 + love.graphics.getHeight()/4)/2;
    animation_time = 0.02;
    bullet_type = "bullet";
    bullet_scale = 1/4;
    width = TILE;
    height = TILE/2;
    margin = TILE/2;
    gun_texture = love.graphics.newImage("assets/spritesheets/ak47_sheet.png");
    gun_sound = love.audio.newSource("assets/sounds/ak47.mp3","stream");
    grid = Anim8.newGrid(TILE,TILE/2,TILE*GUN_FRAMES, TILE);
};

SMG = {
    name = "smg";
    firing_rate = 20;
    shell_cap = 1.75;
    mag_cap = 80;
    bullet_speed = 400;
    damage = 20;
    zoom = 2;
    range = (love.graphics.getWidth()/5 + love.graphics.getHeight()/5)/2;
    animation_time = 0.01;
    bullet_type = "bullet";
    bullet_scale = 1/4;
    width = TILE;
    height = TILE/2;
    margin = TILE/2;
    gun_texture = love.graphics.newImage("assets/spritesheets/smg_sheet.png");
    gun_sound = love.audio.newSource("assets/sounds/smg.mp3","stream");
    grid = Anim8.newGrid(TILE,TILE/2,TILE*GUN_FRAMES, TILE);
}

SNIPER = {
    name = "sniper";
    firing_rate = 0.5;
    shell_cap = 1;
    mag_cap = 5;
    bullet_speed = 2000;
    damage = 200;
    zoom = 1.5;
    range = (love.graphics.getWidth() + love.graphics.getHeight())/2;
    animation_time = 0.22;
    bullet_type = "bullet";
    bullet_scale = 1/3;
    width = TILE;
    height = TILE/2;
    margin = TILE/2;
    gun_texture = love.graphics.newImage("assets/spritesheets/sniper_sheet.png");
    gun_sound = love.audio.newSource("assets/sounds/sniper.mp3","stream");
    grid = Anim8.newGrid(TILE,TILE/2,TILE*GUN_FRAMES, TILE);
}

BLASTER = {
    name = "blaster";
    firing_rate = 1;
    shell_cap = 1;
    mag_cap = 10;
    bullet_speed = 300;
    damage = 200;
    zoom = 2;
    range = (love.graphics.getWidth()/4 + love.graphics.getHeight())/4;
    animation_time = 0.2;
    bullet_type = "bullet";
    bullet_scale = 1;
    width = TILE;
    height = TILE/2;
    margin = TILE/2;
    gun_texture = love.graphics.newImage("assets/spritesheets/blaster_sheet.png");
    gun_sound = love.audio.newSource("assets/sounds/blaster.mp3","stream");
    grid = Anim8.newGrid(TILE,TILE/2,TILE*GUN_FRAMES, TILE);
}

BOW = {
    name = "bow";
    firing_rate = 1;
    shell_cap = 1;
    mag_cap = 10;
    bullet_speed = 150;
    damage = 460;
    zoom = 2;
    range = (love.graphics.getWidth()/4 + love.graphics.getHeight())/4;
    animation_time = 0.2;
    bullet_type = "arrow";
    bullet_scale = 1/3;
    width = TILE;
    height = TILE;
    margin = TILE*(4/5);
    gun_texture = love.graphics.newImage("assets/spritesheets/bow_sheet.png");
    gun_sound = love.audio.newSource("assets/sounds/bow.mp3","stream");
    grid = Anim8.newGrid(17,TILE,17*GUN_FRAMES, TILE*2);
}

local Gun = Weapon:new();

function Gun:new(config,auto)
    local obj = {
        name = config.name;
        width = config.width;
        height = config.height;
        margin = config.margin;
        zoom = config.zoom;
        range = config.range;
        mag_cap = config.mag_cap;
        shell_cap = config.shell_cap;
        bullets = {};
        bullet_type = config.bullet_type;
        firing_time = 1;
        firing_delay = 1/config.firing_rate;
        bullet_speed = config.bullet_speed;
        auto = auto;
        type = auto and "enemy" or "player";
        damage = config.damage;
        bullet_scale = config.bullet_scale;
        texture = config.gun_texture;
        gun_sound = config.gun_sound;
        gun_quad = love.graphics.newQuad(0,0,config.width,config.height,config.gun_texture,1);
        animation_right = Anim8.newAnimation(config.grid('1-6', 1), config.animation_time);
        animation_left = Anim8.newAnimation(config.grid('1-6', 2), config.animation_time);
    };
    setmetatable(obj,self);
    self.__index = self;
    return obj;
end

function Gun:update(dt,x,y,angle)
    self:syncPhysics(x,y,angle);
    self:shoot();
    self:bulletsUpdate(dt);
    self:animate(dt);
    self.firing_time = self.firing_time + dt;
end

function Gun:bulletsUpdate(dt)
    for i,bullet in pairs(self.bullets)  do
        bullet:update(dt);
        if bullet:isExhausted() then
           bullet.body:destroy();
           table.remove(self.bullets,i);
        end
    end
end

function Gun:animate(dt)
    if self.triggered  then
           self.animation_left:update(dt)
           self.animation_right:update(dt)
       else
           self.animation_left:gotoFrame(1);
           self.animation_right:gotoFrame(1);
       end
end

function Gun:shoot()
    if self.animation_left.position >= 6 then
       self:shooting();
    elseif self.name ~= "bow" then
       self:shooting();
   end
end

function Gun:shooting()
    if self.firing_time > self.firing_delay then
        if self.auto then
           if self.triggered then
              self:fire();
              self.gun_sound:play();
           end
        elseif love.mouse.isDown(1) and self.triggered then
           self:fire();
           self.gun_sound:play();
           self.mag_cap = self.mag_cap - 1;
        end
    end
end

function Gun:fire()
    local angle_margins = self:genAngles(self.shell_cap);
    for i = 1,#angle_margins,1 do
    local bullet = Bullet:new(self.type,self.bullet_type,self.x,self.y,self.range,self.angle+angle_margins[i],self.bullet_speed,self.damage,self.bullet_scale);
    bullet:load();
    table.insert(self.bullets,bullet);
    end
    self.firing_time = 0;
end

function Gun:genAngles(n)
    local list = {0};
    for i = 1,math.floor(n/2),1 do
        table.insert(list,i/10);
        table.insert(list,-(i/10));
    end
    return list;
end

function Gun:bulletsDraw()
    for _,bullet in pairs(self.bullets) do
        bullet:draw();
    end
end

function Gun:drawTexture()
    if self:isLeft() then
       self.animation_left:draw(self.texture,-self.width/2,-self.height/2);
    else
       self.animation_right:draw(self.texture,-self.width/2,-self.height/2);
    end
end

function Gun:draw()
    self:bulletsDraw();
    self:drawTransfomation();
    self:drawTexture();
    self:clearTransfomation();
end

function Gun:drawIcon()
    love.graphics.draw(self.texture,self.gun_quad,Camera.x,Camera.y + (love.graphics.getHeight()/2-self.height*2),0,2);
    love.graphics.print("x"..tostring(self.mag_cap),Camera.x + TILE*2,Camera.y + (love.graphics.getHeight()/2-TILE),0,2/3,2/3);
end

return Gun;