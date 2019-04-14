
local composer = require( "composer" )
Object = require("lib.classic.classic")

display.setStatusBar( display.HiddenStatusBar )

math.randomseed( os.time() )


_G.padoruOptions = require("padoru.padoruOpts")
_G.gradientsOpts = require("padoru.sheetOpts")

composer.gotoScene("scene.intro")

