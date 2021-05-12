-----------------
--  Galaxian   --
-----------------

-- Keith Davis --
--  (c) 2021   --
--  ZuniSoft   --

Global = class()

function Global:init()
    -- version
    self.VERSION = 1.3
    
    --screen and animation info
    self.DEFAULT_SCALE = 1.0
    self.SCALE = self.DEFAULT_SCALE
    self.SCREEN_WIDTH = WIDTH
    self.SCREEN_HEIGHT = HEIGHT
    self.FONT_LINE_SPACING = 2
    self.GRID_RIGHT_LIMIT = 26

    -- commands
    self.NOMOVE = 0
    self.MOVELEFT = 1
    self.MOVERIGHT = 2
    
    -- this is static information about each kind of Sprite
    self.PLAYER_IMAGE_BASE = "player"
    self.PLAYER_IMAGES_TO_LOAD = 1
    self.PLAYER_WIDTH = 26
    self.PLAYER_HEIGHT = 40
    self.PLAYER_XOFFSET = 22
    self.PLAYER_X_TWEEK = 11
    self.PLAYER_Y = 200
    self.PLAYER_TYPE = -1
    
    self.PMISSILE_IMAGE_BASE = "pmissile"
    self.PMISSILE_IMAGES_TO_LOAD = 1
    self.PMISSILE_WIDTH = 4
    self.PMISSILE_HEIGHT = 8
    self.PMISSILE_YOFFSET = 34
    self.PMISSILE_TYPE = -2
    
    self.BADGUY1_IMAGE_BASE = "bg1"
    self.BADGUY1_IMAGES_TO_LOAD = 20
    self.BADGUY1_WIDTH = 28
    self.BADGUY1_HEIGHT = 28
    self.BADGUY1_TYPE = 2
    
    self.BADGUY2_IMAGE_BASE = "bg2"
    self.BADGUY2_IMAGES_TO_LOAD = 20
    self.BADGUY2_WIDTH = 28
    self.BADGUY2_HEIGHT = 28
    self.BADGUY2_TYPE = 3
    
    self.BADGUY3_IMAGE_BASE = "bg3"
    self.BADGUY3_IMAGES_TO_LOAD = 20
    self.BADGUY3_WIDTH = 28
    self.BADGUY3_HEIGHT = 28
    self.BADGUY3_TYPE = 4
    
    self.HEADBADGUY_IMAGE_BASE = "g"
    self.HEADBADGUY_IMAGES_TO_LOAD = 20
    self.HEADBADGUY_WIDTH = 28
    self.HEADBADGUY_HEIGHT = 28
    self.HEADBADGUY_TYPE = 5
    
    self.BADGUY_HORZ_SPACE = 35
    self.BADGUY_VERT_SPACE = 24
    self.BADGUY_VERT_START = HEIGHT - 300
    self.BADGUY_ATTACK_RIGHT = true
    self.BADGUY_ATTACK_LEFT = false
    
    self.EMISSILE_IMAGE_BASE = "emissile"
    self.EMISSILE_IMAGES_TO_LOAD = 1
    self.EMISSILE_WIDTH = 4
    self.EMISSILE_HEIGHT = 8
    self.EMISSILE_XOFFSET = 14
    self.EMISSILE_YOFFSET = 24
    self.EMISSILE_TYPE = 6
    
    self.EXTRALIFE_IMAGE_BASE = "extralife0"
    self.EXTRALIFE_HEIGHT = 28
    self.EXTRALIFE_STARTX = 22
    self.EXTRALIFE_HORZ_SPACE = 28
    
    self.LEVELFLAG_IMAGE_BASE = "levelflag"
    self.LEVELFLAG_HEIGHT = 26
    self.LEVELFLAG_STARTX = WIDTH - 25
    self.LEVELFLAG_HORZ_SPACE = 18
    self.LEVELFLAG_NORMAL = 0
    self.LEVELFLAG_WORTH5 = 1
    
    self.SCORE300_IMAGE_BASE = "score300"
    self.SCORE300_IMAGES_TO_LOAD = 10
    
    self.SOUNDS_BASE = "sounds"
    
    -- initial attack frequency
    self.INITIAL_ATTACK_FREQUENCY = 0.001
    self.LEVELINC_ATTACK_FREQUENCY = 0.001
    
    -- initial enemy fire frequency
    self.INITIAL_ENEMY_FIRE_FREQUENCY = 0.01
    self.LEVELINC_ENEMY_FIRE_FREQUENCY = 0.01
    
    -- initial enemy descent and lateral speeds
    self.INITIAL_ENEMY_DESCENT_SPEED = 2
    self.INITIAL_ENEMY_LATERAL_SPEED = 2
    
    -- maximums
    self.MAX_ENEMY_DESCENT_SPEED = 3
    self.MAX_ENEMY_LATERAL_SPEED = 6
    self.NUM_STARS = 30
    
    -- for scoring and explosion
    self.COL_PMISSILE_BADGUY = 1
    self.COL_PLAYER_BADGUY = 2
    self.COL_EMISSILE_PLAYER = 3
    self.COL_PMISSILE_EMISSILE = 4
    
    -- game states
    self.GSTATE_GAMEOVER = 0
    self.GSTATE_PLAYING = 1
    self.GSTATE_CHANGINGLEVEL1 = 2
    self.GSTATE_CHANGINGLEVEL2 = 3
    self.GSTATE_PLAYERDIED = 4
    self.GSTATE_PAUSED = 5
    
    -- these are for free guys
    self.FREE_GUY_INTERVAL = 4500
    
    -- these are stateful things that any game object can change as game events happen
    self.direction = self.NOMOVE
    self.fire = false
    self.playerx = (Global.SCREEN_WIDTH - Global.PLAYER_WIDTH)/2
    self.numBadGuys = 0
    self.loadAnotherMissile = false
    self.playerAlive = false
    self.gridLeftEdge = 0
    self.numHeadBadGuys = 0
    self.playerFired = false
    
    -- for storing high scores
    self.HIGH_SCORE_PREF="hiscore" 
end