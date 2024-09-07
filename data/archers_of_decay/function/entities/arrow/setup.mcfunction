tag @s add dev_satyrn.archers_of_decay.setup

execute if score Use_Wither_Arrows dev_satyrn.archers_of_decay.config >= #true dev_satyrn.enum if entity @s[predicate=archers_of_decay:is_mob_arrow] if entity @e[type=minecraft:wither_skeleton,tag=dev_satyrn.archers_of_decay.wither_archer,dx=0.5,dy=-2,dz=0.5] run function archers_of_decay:entities/arrow/conditional/fired_by_wither_skeleton
