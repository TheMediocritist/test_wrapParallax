import 'CoreLibs/sprites'
import 'CoreLibs/graphics'

local pd<const> = playdate
local gfx<const> = pd.graphics
local geom<const> = pd.geometry

local front = gfx.image.new("front")
local middle = gfx.image.new("middle")
local back = gfx.image.new("back")

local input_vector = geom.vector2D.new(0, 0)

local initialised = false

function initialise()
    -- create parallax
    parallax = Parallax()
    parallax:setSize(400,240)
    parallax:addLayer(front, 0.6)
    parallax:addLayer(middle, 0.2)
    parallax:addLayer(back, 0.1)
    parallax:add()
    
    initialised = true
end

function playdate.update()
    if not initialised then initialise() end
    
    parallax:scroll(input_vector.dx * -5)
    parallax:draw(0, 0, 400, 240)
end


function math.ring(a, min, max)
    if min > max then
        min, max = max, min
    end
    return min + (a - min) % (max - min)
end

class("Parallax").extends(gfx.sprite)

function Parallax:init()
    Parallax.super.init(self)
    self:setSize(400, 240)
    self.layers = {}
end

function Parallax:draw()
    for _, layer in ipairs(self.layers) do
        local img = layer.image
        local offset = layer.offset - (layer.offset % 2)
        
        if offset_x == 0 then
            img:drawTiled(self.x, self.y, self.width, self.height)
            return
        end
        
        local iw, ih = img:getSize()
        local sx = math.abs(offset % iw) - iw + self.x
        
        local cx, cy, cw, ch = playdate.graphics.getClipRect()
        playdate.graphics.setClipRect(draw_x, draw_y, width, height)
        img:drawTiled(sx, self.y, self.width - sx, self.height)
        playdate.graphics.setClipRect(cx, cy, cw, ch)
    end
end

function Parallax:addLayer(img, depth)
    local w, _ = img:getSize()
    local layer = {}
    layer.image = img
    layer.depth = depth
    layer.offset = 0
    layer.width = w
    table.insert(self.layers, 1, layer) -- add the layer to the front of the table
end

function Parallax:scroll(delta)
    for _, layer in ipairs(self.layers) do
        layer.offset = math.ring(layer.offset + (delta * layer.depth), -layer.width, 0)
    end
end

function Parallax:update()
    self:scroll(-self.player.velocity)
end

-- input callbacks
function playdate.leftButtonDown() input_vector.dx = -1 end
function playdate.leftButtonUp() input_vector.dx = 0 end
function playdate.rightButtonDown() input_vector.dx = 1 end
function playdate.rightButtonUp() input_vector.dx = 0 end
function playdate.upButtonDown() input_vector.dy = 1 end
function playdate.upButtonUp() input_vector.dy = 0 end
function playdate.downButtonDown() input_vector.dy = -1 end
function playdate.downButtonUp() input_vector.dy = 0 end
function playdate.AButtonDown() aDown = true end
function playdate.AButtonHeld() aHeld = true end
function playdate.AButtonUp() aDown = false aHeld = false end
function playdate.BButtonDown() bDown = true end
function playdate.BButtonHeld() bHeld = true end
function playdate.BButtonUp() bDown = false bHeld = false end