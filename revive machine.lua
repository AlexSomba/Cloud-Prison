jail = {}

-- Revive Machine
jail.machines = {
    [1] = {
        -- trigger position if active
        trigger = "medButton",
        -- how many times it can be reused before it gets broken?
        reuse = 0,
        -- is the main machine activated?
        active = false,
        -- secondary machines
        secondary_machines = {
            [1] = {
                -- position in x, y tiles
                coordinates = {30,153},
                -- trigger position if active
                trigger = "medON1",
                -- how many gut bombs to be used before the machine to activate
                gut_bombs = 1,
                -- is active ?
                active = false
            },
            [2] = {
                coordinates = {25,158},
                trigger = "medON2",
                gut_bombs = 1,
                active = false
            },
            [3] = {
                coordinates = {31,159},
                trigger = "medON3",
                gut_bombs = 1,
                active = false
            }
        }
    },
    [2] = {
        trigger = "",
        reuse = "infinite",
        active = false,
        secondary_machines = {
            [1] = {
                coordinates = {102,58},
                trigger = "lifeM1",
                gut_bombs = 1,
                active = false
            }
        }
    },
}

function _projectile(id,weapon,x,y)
    print("                ")
    for index, _ in ipairs(jail.machines) do
        -- main machine is active?
        if not jail.machines[index].active then
            print("Debug -- Not Active -- ")
            local reuse = jail.machines[index].reuse
            -- is the machine broken?
            if reuse == "infinite" or reuse >= 0 then
                print("Debug -- Reuse -- ")
                for key, _ in pairs(jail.machines[index].secondary_machines) do
                    local sec_coordinates = jail.machines[index].secondary_machines[key].coordinates
                    print("Debug -- Pairs -- ")
                    -- is the projectile a gut bomb?
                    if weapon == 86 then
                        -- is the item projected to the right position?
                        if math.floor(x/32) == sec_coordinates[1] and math.floor(y/32) == sec_coordinates[2] then
                            print("Debug -- Hit Coordinates -- "..sec_coordinates[1].." -- "..sec_coordinates[2])
                            local sec_active = jail.machines[index].secondary_machines[key].active
                            -- is the secondary machine active?
                            if not sec_active then
                                local sec_gut_bombs = jail.machines[index].secondary_machines[key].gut_bombs
                                if sec_gut_bombs > 0 then
                                    -- deduct one gut bomb for each individual throw to a machine
                                    sec_gut_bombs = sec_gut_bombs - 1
                                    print("Debug -- Gut Bombs -- "..sec_gut_bombs)
                                end
                                -- activate the machine if gut bombs variable has reached zero
                                if sec_gut_bombs == 0 then
                                    jail.machines[index].secondary_machines[key].active = true

                                    local _trigger = jail.machines[index].secondary_machines[key].trigger
                                    -- activate secondary machine animations on map
                                    parse("trigger ".._trigger)
                                    print("Debug -- Activated Secondary Machine -- ".._trigger)

                                    for m, machine in ipairs(jail.machines) do
                                        local activeSecondaryMachines = 0
                                        for sm, secondary_machine in ipairs(machine.secondary_machines) do
                                            if secondary_machine.active then
                                                activeSecondaryMachines = activeSecondaryMachines + 1
                                            end
                                            print(activeSecondaryMachines.." -- ".. #machine.secondary_machines)
                                        end
                                        if activeSecondaryMachines == #machine.secondary_machines then
                                            -- deduct the reuse variable by one
                                            if reuse ~= "infinite" then
                                                if reuse ~= -1 then
                                                    jail.machines[index].reuse = jail.machines[index].reuse - 1
                                                end
                                            end
                                            -- activate the main machine
                                            jail.machines[m].active = true
                                            -- trigger map machine animation
                                            parse("trigger medButton")
                                            print("Debug -- Activated Machine " .. m .. " --")
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            else
                msg2(id, "Congratz, you broke the machine. D:")
            end
        end
    end
end
addhook("projectile","_projectile")

function _usebutton(id, x, y)
    if entity(27,153,"state") == true then
        for index, _ in ipairs(jail.machines) do
            for key, _ in pairs(jail.machines[index]) do
                jail.machines[index].active = false
                print(jail.machines[index].active)
            end
            for key, _ in pairs(jail.machines[index].secondary_machines) do
                jail.machines[index].secondary_machines[key].active = false
                jail.machines[index].secondary_machines[key].gut_bombs = 1
                print(jail.machines[index].secondary_machines[key].active)
            end
        end
    end
end
addhook("usebutton","_usebutton")
