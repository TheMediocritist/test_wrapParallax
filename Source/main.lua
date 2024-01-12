-- parallax implementation by frankbsad (Rob): https://devforum.play.date/t/a-list-of-helpful-libraries-and-code/221/93
-- image wrapping implementation by Dustin Mierau: https://devforum.play.date/t/a-list-of-helpful-libraries-and-code/221/91

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
    parallax = Parallax(200, 120, 360, 200)
    parallax:addLayer(front, 0.6)
    parallax:addLayer(middle, 0.2)
    parallax:addLayer(back, 0.1, 1)
    
    initialised = true
end

function playdate.update()
    if not initialised then initialise() end
    
    if input_vector.dx ~= 0 then parallax:scroll(input_vector.dx * -5) end
    
    gfx.sprite.update()
    
end

class("Parallax").extends(gfx.sprite)

function Parallax:init(x, y, width, height)
    Parallax.super.init(self)
    self.canvas = gfx.image.new(width, height)
    self.redraw = true
    self:setImage(self.canvas)
    self.layers = {}
    self:moveTo(x, y)
    
    self:add()

end

function Parallax:addLayer(img, depth, minScroll)
    local w, _ = img:getSize()
    local layer = {}
    layer.image = img
    layer.depth = depth
    layer.minimum_scroll = minScroll or 2
    layer.offset = 0
    layer.width = w
    table.insert(self.layers, 1, layer) -- add the layer to the front of the table
end

function Parallax:update()
    if self.redraw then
        playdate.graphics.lockFocus(self.canvas)
        playdate.graphics.clear()
        playdate.graphics.setClipRect(0, 0, self.width, self.height)
        
        for _, layer in ipairs(self.layers) do
            local img = layer.image
            
            -- lock offset to minimum scroll (use 2 to reduce flashing)
            local offset = layer.offset - (layer.offset % layer.minimum_scroll)
            
            img:drawTiled(offset, 0, self.width - offset, self.height)

        end
        playdate.graphics.unlockFocus()
        self:setImage(self.canvas)
        self.redraw = false
    end
end

function Parallax:scroll(delta)
    for _, layer in ipairs(self.layers) do
        layer.offset = math.ring(layer.offset + (delta * layer.depth), -layer.width, 0)
    end
    self.redraw = true
end

function math.ring(a, min, max)
    if min > max then
        min, max = max, min
    end
    return min + (a - min) % (max - min)
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
