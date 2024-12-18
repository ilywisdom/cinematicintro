TOOL.Category = "Cinematic Intro"
TOOL.Name = "Position Grabber"
TOOL.Command = nil
TOOL.ConfigName = ""

if CLIENT then
    language.Add("tool.tool_ci.name", "Position Grabber")
    language.Add("tool.tool_ci.desc", "Grab positions and angles for cinematic intro")
    language.Add("tool.tool_ci.0", "Left click to set start position, Right click to set end position")
end

local startPos
local startAng
local endPos 
local endAng

function TOOL:LeftClick()
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    startPos = ply:GetPos()
    startAng = ply:EyeAngles()
    
    ply:ChatPrint("Start Position Set!")
    return true
end

function TOOL:RightClick()
    if CLIENT then return true end
    
    local ply = self:GetOwner()
    endPos = ply:GetPos() 
    endAng = ply:EyeAngles()
    
    -- Format the section code
    local sectionCode = string.format([[
    {
        startPos = Vector(%f, %f, %f),
        startAng = Angle(%f, %f, %f),
        endPos = Vector(%f, %f, %f), 
        endAng = Angle(%f, %f, %f)
    }]], 
    startPos.x, startPos.y, startPos.z,
    startAng.p, startAng.y, startAng.r,
    endPos.x, endPos.y, endPos.z,
    endAng.p, endAng.y, endAng.r
    )
    
    -- Write to config file
    local path = "cinematicintro/lua/cinematicintro/sh_config.lua"
    if not file.Exists(path, "LUA") then
        file.Write(path, "")
    end
    
    local f = file.Open(path, "r", "LUA")
    if f then
        local content = f:Read(f:Size())
        f:Close()
        
        -- Find the Sections table and add new section
        local insertPos = content:find("CinematicIntro.Config.Sections = {}")
        if insertPos then
            local newContent = content:sub(1, insertPos + 35) .. "\ntable.insert(CinematicIntro.Config.Sections, " .. sectionCode .. ")" .. content:sub(insertPos + 36)
            
            -- Write the updated content
            f = file.Open(path, "w", "LUA")
            if f then
                f:Write(newContent)
                f:Close()
                ply:ChatPrint("Position set saved to config!")
            else
                ply:ChatPrint("Error saving position set!")
            end
        else
            ply:ChatPrint("Could not find Sections table in config!")
        end
    else
        ply:ChatPrint("Error reading config file!")
    end
    
    return true
end

function TOOL:Think()
    -- Add visual feedback if needed
end
