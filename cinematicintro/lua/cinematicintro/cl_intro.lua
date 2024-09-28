local pPlayer = LocalPlayer()
local function CinematicIntroStart()
    
    local scrw, scrh
    scrw = ScrW()
    scrh = ScrH()
    local CinematicIntroFrame = vgui.Create("DFrame")
    CinematicIntroFrame:SetSize(scrw, scrh)
    CinematicIntroFrame:Center()
    CinematicIntroFrame:MakePopup()
    CinematicIntroFrame:ShowCloseButton(false)
    CinematicIntroFrame:SetDraggable(false)
    CinematicIntroFrame:SetTitle("")
    local CinematicIntroButton = vgui.Create("DButton", CinematicIntroFrame)
    CinematicIntroButton:SetSize(scrw / 12, scrh / 24)
    CinematicIntroButton:Center()
    CinematicIntroButton:SetText("")

    CinematicIntroButton.Paint = function(me, w, h)
        local btncolor = Color(0,0,0,195)

        if CinematicIntroButton:IsHovered() then
            btncolor = Color(86,3,3,131)
        else
            btncolor = Color(0,0,0,195)
        end

        draw.RoundedBox( 0, 0, 0, w, h, btncolor )
        draw.SimpleText("Play", "CinematicIntro.Button.Font", w / 2 + 2, h * .46, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
    end

    function CinematicIntroButton:DoClick()
        hook.Remove("CalcView", "CinematicIntroCalcView")
        surface.PlaySound("ilywisdom/notify.wav")
        CinematicIntroFrame:Remove()
    end
    -- Descriptions just go like "this a description" If you add another one the make sure to put a comma on the top one!
    local descriptions = CinematicIntro.Config.Descriptions
    local lps = 10 -- (letters per second)
    local sae = 3 -- how long to wait between finishing the line and switching to the next one (seconds after end)
    -- DON'T CHANGE THESE --
    local description = math.ceil(math.random(#descriptions))
    local step = 1
    local descriptionStartTime = RealTime()
    local descriptionStepTime = RealTime()
    -- DON'T CHANGE THESE --

    CinematicIntroFrame.Paint = function(me, w, h)
        surface.SetAlphaMultiplier(math.abs(math.sin(CurTime() * 3)))
        surface.SetAlphaMultiplier(1)
        draw.SimpleText(CinematicIntro.Config.ServerName, "CinematicIntro.Title.Font", w / 2 + 2, h * .43, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        draw.SimpleText(string.sub(descriptions[description], 1, step), "CinematicIntro.Description.Font", w / 2, h * .56, color_white, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

        if RealTime() - descriptionStepTime >= 1 / lps then step = step + 1; descriptionStepTime = RealTime() end

        if step > #descriptions[description] + (sae * lps) then
            step = 1
            descriptionStartTime = math.floor(RealTime())
            local prevDesc = description 
            while prevDesc == description do
                description = math.ceil(math.random(#descriptions))
            end

            if description > #descriptions then
                description = 1
            end
        end
    end

    -- Sections for CalcView glide
    local sect1 = {
        startPos = Vector(-7584, 1547, 516.952759),
        startAng = Angle(3, 119, 0.000000),
        endPos = Vector(-5101, 1699, 516.952759),
        endAng = Angle(-1, 100, 0.000000)
    }

    local sect2 = {
        startPos = Vector(-4107, 6071, 559.097412),
        startAng = Angle(1, -159, 0.000000),
        endPos = Vector(-6800, 7223, 557.347778),
        endAng = Angle(3, -89, 0.000000)
    }

 -- These are extra sections for the map preview uncomment these if you want more
  --  local sect3 = {
      --  startPos = Vector(8611, 12143, 167),
     --   startAng = Angle(8, 177, 0),
    --    endPos = Vector(8636, 14495, 281),
     --   endAng = Angle(9, -178, 0)
   -- }

    --local sect4 = {
    --    startPos = Vector(14154, 9397, 298),
    --    startAng = Angle(6, 116, 0.),
    --    endPos = Vector(13845, 13714, 396),
    ----    endAng = Angle(15, -4, 0)
    --}


  --  local sect6 = {
  --      startPos = Vector(-10375, -9547, 265),
 --       startAng = Angle(14, -96, 0),
 ---       endPos = Vector(-14659, -11298, 247),
 --       endAng = Angle(4, 79, 0)
--
  --  }
  -- if you add more sections then use a comma and put the sections you un commented
    local sections = { sect1, sect2}

    -- Lerp vars
    local section = 1
    local lerpStartTime = RealTime()

    -- CalcView hook
    hook.Add( "CalcView", "CinematicIntroCalcView", function( _, _, _, fov )
        local realTime = RealTime()
        local lerpTime = (realTime - lerpStartTime) / 10

        if lerpTime > 1 then
            section = section + 1
            lerpStartTime = RealTime()

            if section > #sections then
                section = 1
            end
        end


        local pos = LerpVector(lerpTime, sections[section].startPos, sections[section].endPos)
        local ang = LerpAngle(lerpTime, sections[section].startAng, sections[section].endAng)

        local view = {
            origin = pos,
            angles = ang,
            fov = fov,
            drawviewer = true
        }

        return view
    end )
end


net.Receive("CinematicIntroPlayerSpawn", CinematicIntroStart)
hook.Add( "InitPostEntity", "Ready", function()
	net.Start( "CinematicIntroPlayerSpawn" )
	net.SendToServer()
end )