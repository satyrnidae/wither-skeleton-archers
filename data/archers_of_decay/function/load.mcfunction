scoreboard objectives add dev_satyrn.archers_of_decay.used_skeleton_spawn_egg minecraft.used:skeleton_spawn_egg
scoreboard objectives add dev_satyrn.archers_of_decay.config dummy {"text":"Archers of Decay - Configuration"}
scoreboard objectives add dev_satyrn.enum dummy
scoreboard players set #true dev_satyrn.enum 1
scoreboard players set #false dev_satyrn.enum 0

execute unless score #version dev_satyrn.archers_of_decay.config matches ${config_schema} run function archers_of_decay:objectives/init_config


