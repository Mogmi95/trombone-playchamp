class("Score").extends()

local gfx <const> = playdate.graphics

local CONFIG_SCORE_DIGITS = 6
local CONFIG_DIGIT_WIDTH = 15
local CONFIG_DIGIT_HEIGHT = 20
local CONFIG_TEXT_X_LEFT_MARGIN = 20
local CONFIG_TEXT_X_RIGHT_MARGIN = 10
local CONFIG_TEXT_Y_TOP_MARGIN = 5
local CONFIG_TEXT_Y_BOTTOM_MARGIN = 5
local CONFIG_SCORE_WIDTH = CONFIG_TEXT_X_LEFT_MARGIN + CONFIG_DIGIT_WIDTH * CONFIG_SCORE_DIGITS + CONFIG_TEXT_X_RIGHT_MARGIN
local CONFIG_SCORE_HEIGHT = CONFIG_TEXT_Y_TOP_MARGIN + CONFIG_DIGIT_HEIGHT + CONFIG_TEXT_Y_BOTTOM_MARGIN

local CONFIG_ANIMATION_DURATION = 8

function printScoreDimensions()
    print("CONFIG_SCORE_WIDTH : " .. CONFIG_SCORE_WIDTH)
    print("CONFIG_SCORE_HEIGHT : " .. CONFIG_SCORE_HEIGHT)
end

function getScoreWidth()
    return CONFIG_SCORE_WIDTH
end

function Score:init(positionX, positionY)
    self.currentScore = 000000
    self.positionX = positionX
    self.positionY = positionY
    self.animationTimer = 0
    self.backgroundImage = gfx.image.new("/Assets/score.png")
    -- printScoreDimensions()
end

function Score:drawBackground()
    self.backgroundImage:draw(self:getX(), self:getY())
end

-- Draw a digit given its position.
-- Position follows Lua array "rules"
-- SCORE = 472849
-- 1 = "4", 2 = "7", 3 = "2"...
function Score:drawDigit(position, value)
    local textXCenter = self:getX() + CONFIG_TEXT_X_LEFT_MARGIN + CONFIG_DIGIT_WIDTH * (position - 1) + CONFIG_DIGIT_WIDTH / 2 - 1
    local textYCenter = self:getY() + CONFIG_TEXT_Y_TOP_MARGIN + 1
    gfx.drawTextAligned("" .. value, textXCenter, textYCenter, kTextAlignment.center)
end

function Score:getX()
    return self.positionX
end

function Score:getY()
    return self.positionY - (self.animationTimer / 2) * (self.animationTimer % 4)
end

function Score:draw()
    self:drawBackground()
    for i = 1, CONFIG_SCORE_DIGITS do
        self:drawDigit(i, math.floor((self.currentScore/ 10^(CONFIG_SCORE_DIGITS - i)) % 10))
    end
    if self.animationTimer > 0 then
        self.animationTimer -= 1
    end
end

function Score:addPoints(points)
    self.animationTimer = CONFIG_ANIMATION_DURATION
    self.currentScore += points
end