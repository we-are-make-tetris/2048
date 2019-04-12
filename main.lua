local composer = require( "composer" )
Object = require("lib.classic.classic")

display.setStatusBar( display.HiddenStatusBar )

math.randomseed( os.time() )

composer.gotoScene("scene.intro")