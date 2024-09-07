# Unless the firing entity is holding a flame bow, extinguish the arrow
execute unless entity @e[tag=dev_satyrn.archers_of_decay.wither_archer,dx=0.5,dy=-2,dz=0.5,predicate=archers_of_decay:has_flame_bow] run data modify entity @s Fire set value 0

data merge entity @s {item: {components: {"minecraft:potion_contents":{custom_color:3484199,custom_effects:[{id:"minecraft:wither",duration:200,amplifier:0}]}}}}

execute store result entity @s item.components.minecraft:potion_contents.custom_effects[0].duration int 1 run scoreboard players get Wither_Duration dev_satyrn.archers_of_decay.config
execute store result entity @s item.components.minecraft:potion_contents.custom_effects[0].amplifier int 1 run scoreboard players get Wither_Level dev_satyrn.archers_of_decay.config

tag @s add global.ignore
