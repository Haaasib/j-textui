Config = {
    DefaultKey = {
        Enable = true,
        Key = "E"
    },
    Areas = {
        {
            data = {
                type = "3dtext", -- 3dtext or textui
                coords = vector3(0, 0, 0), 
                displayDist = 6,
                interactDist = 2,
                enableKeyClick = true,
                keyNum = 38, -- Key number
                key = "E", -- Key name
                text = "Label",
                job = "all"
            },
            onKeyClick = function()
                -- Write your export or events here
            end
        },
        {
            data = {
                type = "textui", -- textui or 3dtext
                coords = vector3(0, 0, 0), 
                dist = 3,
                keyNum = 38, -- Key number
                key = "E", -- Key name
                text = "Label",
                job = "all"
            },
            onKeyClick = function()
                -- Write your export or events here
            end
        }
    }
}