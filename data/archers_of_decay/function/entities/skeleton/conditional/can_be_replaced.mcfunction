summon minecraft:wither_skeleton ~ ~ ~ {Tags:[dev_satyrn.archers_of_decay.new_archer, dev_satyrn.archers_of_decay.wither_archer, global.ignore]}

data modify entity @e[type=minecraft:wither_skeleton, tag=dev_satyrn.archers_of_decay.new_archer, limit=1, distance=..0.25, sort=nearest] ArmorItems set from entity @s ArmorItems
data modify entity @e[type=minecraft:wither_skeleton, tag=dev_satyrn.archers_of_decay.new_archer, limit=1, distance=..0.25, sort=nearest] ArmorDropChances set from entity @s ArmorDropChances
data modify entity @e[type=minecraft:wither_skeleton, tag=dev_satyrn.archers_of_decay.new_archer, limit=1, distance=..0.25, sort=nearest] CanPickUpLoot set from entity @s CanPickUpLoot
data modify entity @e[type=minecraft:wither_skeleton, tag=dev_satyrn.archers_of_decay.new_archer, limit=1, distance=..0.25, sort=nearest] HandItems set from entity @s HandItems
data modify entity @e[type=minecraft:wither_skeleton, tag=dev_satyrn.archers_of_decay.new_archer, limit=1, distance=..0.25, sort=nearest] HandDropChances set from entity @s HandDropChances
data modify entity @e[type=minecraft:wither_skeleton, tag=dev_satyrn.archers_of_decay.new_archer, limit=1, distance=..0.25, sort=nearest] Rotation set from entity @s Rotation
data modify entity @e[type=minecraft:wither_skeleton, tag=dev_satyrn.archers_of_decay.new_archer, limit=1, distance=..0.25, sort=nearest] DeathLootTable set value "archers_of_decay:entities/wither_skeleton_archer"

tag @e[type=minecraft:wither_skeleton, tag=dev_satyrn.archers_of_decay.new_archer, limit=1, distance=..0.25, sort=nearest] remove dev_satyrn.archers_of_decay.new_archer

# Throw the executing entity into the void and kill them
data modify entity @s DeathLootTable set value "minecraft:empty"
teleport @s ~ -10000 ~
kill @s
