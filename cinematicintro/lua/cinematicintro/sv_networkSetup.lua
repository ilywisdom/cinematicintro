util.AddNetworkString("CinematicIntroPlayerSpawn")

-- Player Spawn Network

net.Receive( "CinematicIntroPlayerSpawn", function( len, ply )
    net.Start("CinematicIntroPlayerSpawn")
    net.Send(ply)
end )
hook.Add( "CanPlayerSuicide", "AllowOwnerSuicide", function( ply )
    return false
end )