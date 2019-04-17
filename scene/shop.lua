local composer = require("composer")
local widget = require( "widget" )
local json = require( "json" )

local achiveBd = require( "bd.achiveBd" )

local scene = composer.newScene()

local complete = {}

local backColor = {0.09, 0.1, 0.15}
local darkFrontColor = {0.39, 0.16, 0.16}
local frontColor = {0.46, 0.07, 0.07}


local function downloadData()
    local path = system.pathForFile( "shopSave.json", system.DocumentsDirectory )
     
    -- Open the file from the path
    local fh = io.open( path, "r" )

    if fh then
        
        complete = json.decode(fh:read( "*a" ))
        
    else

        fh = io.open( path, "w" )
     
        if fh then
            local data = {}
            for i=1, 25 do
                table.insert(data, false)
            end
            fh:write( json.encode(data) )
            complete = data
        end

    end
      
    io.close( fh )
end


local function onRowRender( event )
 
    -- Get reference to the row group
    local row = event.row
    -- Cache the row "contentWidth" and "contentHeight" because the row bounds can change as children objects are added
    local rowHeight = row.contentHeight
    local rowWidth = row.contentWidth
--------------------------------------------------------------------------    
    if row.index ~= 2 then
        local rowTitle = display.newRect(row, 0, 0, rowWidth-20, rowHeight - 10 )
        rowTitle:setFillColor(unpack(frontColor))
        
        rowTitle.x = rowWidth / 2
        rowTitle.y = rowHeight / 2
    --------------------------------------------------------------------------
        local face = display.newCircle(row, 0, 0, rowHeight * 0.4)
        face.strokeWidth = 7
        face:setStrokeColor(unpack(backColor))


        face.x = rowHeight * 0.55
        face.y = rowHeight * 0.5

        local name

        if complete[row.index] == false then
            name = display.newText(row, '???', 0, 0, nil, 40)
            --------------------------------------------------------------------------
            face:setFillColor(unpack(darkFrontColor))
            --------------------------------------------------------------------------
            local question = display.newText(row, '?', 0, 0, nil, 110)
            question:setFillColor(unpack(backColor))

            question.x = face.x
            question.y = face.y
        else
            name = display.newText(row, achiveBd.list[row.index].name, 0, 0, nil, 40)
            --------------------------------------------------------------------------
            face.fill = {type = 'image', filename = achiveBd.list[row.index].face}
        end

        name.x = 300
        name.y = 30
    --------------------------------------------------------------------------
        local description = display.newText(row, achiveBd.list[row.index].text, 0, 0, nil, 40)

        description.x, description.y = 300, 100
    --------------------------------------------------------------------------
        local split = display.newText(row, '____________', 0, 0, nil, 40)

        split.x = 300
        split.y = 50


    end
--------------------------------------------------------------------------

end

function scene:create( event )

    local sceneGroup = self.view

    downloadData()

    local label = display.newRect(sceneGroup, display.contentCenterX, -30, display.contentWidth, 110)
    label:setFillColor(unpack(backColor))
    local labelText = display.newText(sceneGroup, 'Store', display.contentCenterX, -30, nil, 110)
    local tableView = widget.newTableView(
        {
            backgroundColor = backColor,
            height = display.actualContentHeight-100,
            width = display.actualContentWidth,
            
            noLines = true,
            onRowRender = onRowRender,
            onRowTouch = onRowTouch,
            listener = scrollListener
        }
    )
    tableView.x = display.contentCenterX
    tableView.y = display.contentCenterY+60

    for i = 1, 25 do
        tableView:insertRow(
            {
                rowHeight = 150,
                rowColor = { default=backColor, over={1,0.5,0} },
                lineColor = { 0.5, 0.5, 0.5, 0 },

            }
        )
    end

    local cross = widget.newButton({
        onPress = function() composer.hideOverlay('slideUp', 200) end,
        label = "x",
        labelColor = {default={1}, over={1}},
        fontSize = 70,
        
        top = -80,
        left = 519,

        shape = "rect",
        width = 100,
        height = 100,
        fillColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeColor = { default={1,1,1,0}, over={1,1,1,0} },
        strokeWidth = 4
    })

    sceneGroup:insert(tableView)
    sceneGroup:insert(cross)
end

function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen

    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene