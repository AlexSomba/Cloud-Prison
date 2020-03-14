prison = {}

prison.handcuffs = {
    config = {
        image = "gfx/cloud/prison/handcuffs.png",
        sfx = {
            lock = "cloud/prison/ChainLock.wav",
            destroy = "cloud/prison/ChainBreak.wav",
            hit = "cloud/prison/ChainHit.wav"
        },
        properties = {
            endurance = math.random(3,10)
        }
    }
}

nullifyHandcuffs = function(id)
    if prison[id].handcuffs then
        prison[id].handcuffs = false
        prison[id].handcuffs_endurance = prison.handcuffs.config.properties.endurance
        freeimage(prison[id].handcuffs_image)
    end
end

function join_module_prison(id)
    prison[id] = {}
    prison[id].handcuffs = false
    prison[id].handcuffs_endurance = prison.handcuffs.config.properties.endurance
end
addhook("join", "join_module_prison", -999999)

function attack_module_prison(id)
    local rot = player(id, "rot")
    local angle = math.rad(math.abs(rot +90)) - math.pi
    local x = player(id,"tilex") + math.cos(angle) * 1
    local y = player(id,"tiley") + math.sin(angle) * 1

	if prison[id].handcuffs then
        -- move player cuffs image with player rotation and angle when attacking
		if rot < -90 then rot = rot + 360 end
        -- is the player near an entity?
		if tile(x, y, "property") >= 1 and tile(x, y, "property") <= 4 then
            -- damage handcuff
			if prison[id].handcuffs_endurance > 0 then
                prison[id].handcuffs_endurance = prison[id].handcuffs_endurance - 1
            else
                -- release player
                prison[id].handcuffs = false
                freeimage(prison[id].handcuffs_image)
                parse("strip "..id.." 78")
            end
            parse("sv_soundpos "..prison.handcuffs.config.sfx.hit.." "..player(id, "x").." "..player(id, "y"))
        end
	end
end
addhook("attack", "attack_module_prison", -999999)

function hit_module_prison(id, source, weapon)
	if weapon == 78 then
        if player(source, "team") ~= player(id, "team") then
            if not prison[id].handcuffs then
    			prison[id].handcuffs = true
    			prison[id].handcuffs_endurance = prison.handcuffs.config.properties.endurance
                prison[id].handcuffs_image = image(prison.handcuffs.config.image, 2, -1, id+200)
    			parse("equip "..id.." 78")
    			parse("setweapon "..id.." 78")
                parse("sv_soundpos "..prison.handcuffs.config.sfx.lock.." "..player(id, "x").." "..player(id, "y"))
            else
    			nullifyHandcuffs(id)
                parse("sv_soundpos "..prison.handcuffs.config.sfx.destroy.." "..player(id, "x").." "..player(id, "y"))
    		end
        end
--        return 1
	end
end
addhook("hit", "hit_module_prison")

function spawn_module_prison(id)
    nullifyHandcuffs(id)
end
addhook("spawn", "spawn_module_prison", -999999)

function select_module_prison(id)
    if prison[id].handcuffs then parse("setweapon "..id.." 78") end
end
addhook("select", "select_module_prison", -999999)

function walkover_module_prison(id)
	if prison[id].handcuffs then return 1 end
end
addhook("walkover", "walkover_module_prison", -999999)

function drop_module_prison(id)
	if prison[id].handcuffs then return 1 end
end
addhook("drop", "drop_module_prison", -999999)

function die_module_prison(victim)
	if prison[victim].handcuffs then parse("strip "..victim.." 78") end
end
addhook("die", "die_module_prison", -999999)
