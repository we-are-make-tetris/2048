--
-- created with TexturePacker - https://www.codeandweb.com/texturepacker
--
-- $TexturePacker:SmartUpdate:505a06bb9b04d7bb0564afddd4bef69f:0acfe77715a08eea5d356715255e77dd:9bbfb9effa76379849031ee0295cdd44$
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
            -- padoru1
            x=1,
            y=1,
            width=400,
            height=400,

        },
        {
            -- padoru2
            x=403,
            y=403,
            width=400,
            height=400,

        },
        {
            -- padoru3
            x=403,
            y=805,
            width=400,
            height=400,

        },
        {
            -- padoru4
            x=403,
            y=1207,
            width=400,
            height=400,

        },
        {
            -- padoru5
            x=403,
            y=1609,
            width=400,
            height=400,

        },
        {
            -- padoru6
            x=805,
            y=1,
            width=400,
            height=400,

        },
        {
            -- padoru7
            x=805,
            y=403,
            width=400,
            height=400,

        },
        {
            -- padoru8
            x=805,
            y=805,
            width=400,
            height=400,

        },
        {
            -- padoru9
            x=805,
            y=1207,
            width=400,
            height=400,

        },
        {
            -- padoru10
            x=1,
            y=403,
            width=400,
            height=400,

        },
        {
            -- padoru11
            x=1,
            y=805,
            width=400,
            height=400,

        },
        {
            -- padoru12
            x=1,
            y=1207,
            width=400,
            height=400,

        },
        {
            -- padoru13
            x=1,
            y=1609,
            width=400,
            height=400,

        },
        {
            -- padoru14
            x=403,
            y=1,
            width=400,
            height=400,

        },
    },

    sheetContentWidth = 1206,
    sheetContentHeight = 2010
}

SheetInfo.frameIndex =
{

    ["padoru1"] = 1,
    ["padoru2"] = 2,
    ["padoru3"] = 3,
    ["padoru4"] = 4,
    ["padoru5"] = 5,
    ["padoru6"] = 6,
    ["padoru7"] = 7,
    ["padoru8"] = 8,
    ["padoru9"] = 9,
    ["padoru10"] = 10,
    ["padoru11"] = 11,
    ["padoru12"] = 12,
    ["padoru13"] = 13,
    ["padoru14"] = 14,
}

function SheetInfo:getSheet()
    return self.sheet;
end

function SheetInfo:getFrameIndex(name)
    return self.frameIndex[name];
end

return SheetInfo
