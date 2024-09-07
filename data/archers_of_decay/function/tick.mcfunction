execute as @e[type=minecraft:skeleton, tag=!global.ignore, tag=!global.ignore.kill, tag=!global.ignore.pos, tag=!dev_satyrn.archers_of_decay.setup] at @s run function archers_of_decay:entities/skeleton/setup

execute as @e[type=minecraft:arrow, tag=!global.ignore, tag=!dev_satyrn.archers_of_decay.setup] at @s run function archers_of_decay:entities/arrow/setup

scoreboard players set @a dev_satyrn.archers_of_decay.used_skeleton_spawn_egg 0
