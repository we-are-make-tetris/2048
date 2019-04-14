--
-- created with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:2413209409b816e2925d33e97a489ead:fd98865baaaa35b7c5f29e921a2e576d:483dda065966ab4aa35515140767f765$
--
-- local sheetInfo = require("mysheet")
-- local myImageSheet = graphics.newImageSheet( "mysheet.png", sheetInfo:getSheet() )
-- local sprite = display.newSprite( myImageSheet , {frames={sheetInfo:getFrameIndex("sprite")}} )
--

local SheetInfo = {}

SheetInfo.sheet =
{
    frames = {
    
        {
            -- coh1
            x=0,
            y=0,
            width=100,
            height=100,

        },
        {
            -- coh2
            x=100,
            y=0,
            width=100,
            height=100,

        },
        {
            -- coh3
            x=200,
            y=0,
            width=100,
            height=100,

        },
        {
            -- coh4
            x=300,
            y=0,
            width=100,
            height=100,

        },
        {
            -- coh5
            x=400,
            y=0,
            width=100,
            height=100,

        },
        {
            -- coh6
            x=500,
            y=0,
            width=100,
            height=100,

        },
        {
            -- coh7
            x=600,
            y=0,
            width=100,
            height=100,

        },
        {
            -- coh8
            x=700,
            y=0,
            width=100,
            height=100,

        },
        {
            -- coh9
            x=800,
            y=0,
            width=100,
            height=100,

        },
        {
            -- coh10
            x=900,
            y=0,
            width=100,
            height=100,

        },
        {
            -- coh11
            x=1000,
            y=0,
            width=100,
            height=100,

        },
    },

    sheetContentWidth = 1100,
    sheetContentHeight = 100
}

SheetInfo.frameIndex =
{

    ["coh1"] = 1,
    ["coh2"] = 2,
    ["coh3"] = 3,
    ["coh4"] = 4,
    ["coh5"] = 5,
    ["coh6"] = 6,
    ["coh7"] = 7,
    ["coh8"] = 8,
    ["coh9"] = 9,
    ["coh10"] = 10,
    ["coh11"] = 11,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
