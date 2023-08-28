Camera = {};

function Camera:load(max_x,max_y,scale)
    self.x = 0;
    self.y = 0;
    self.max_y = max_y;  
    self.max_x = max_x;
    self.scale = scale;
end

function Camera:update(x,y,scale)
    self.scale = scale;
    self.x = x - love.graphics.getWidth() / 2 /self.scale;
    self.y = y - love.graphics.getWidth() / 2 /self.scale;
     
    if self.x < 0 then
        self.x = 0;
    end

    if self.x + love.graphics.getWidth()/2 > self.max_x then
        self.x = self.max_x - love.graphics.getWidth()/2;
    end

    if self.y + love.graphics.getHeight()/2 > self.max_y then
        self.y = self.max_y - love.graphics.getHeight()/2;
    end

    if self.y < 0 then
        self.y = 0;
    end
end

function Camera:apply()
    love.graphics.push()
    love.graphics.scale(self.scale,self.scale);
    love.graphics.translate(-self.x, -self.y);
end

function Camera:clear()
    love.graphics.pop();
end
