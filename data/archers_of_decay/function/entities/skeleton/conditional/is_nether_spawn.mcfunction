# We will not replace spawn egg spawned skeletons unless the config specifies otherwise.
execute if score Replace_Spawn_Egg_Skeletons dev_satyrn.archers_of_decay.config >= #true dev_satyrn.enum run function archers_of_decay:entities/skeleton/conditional/can_be_replaced
execute if score Replace_Spawn_Egg_Skeletons dev_satyrn.archers_of_decay.config <= #false dev_satyrn.enum unless entity @p[distance=..5,predicate=archers_of_decay:used_skeleton_spawn_egg] run function archers_of_decay:entities/skeleton/conditional/can_be_replaced
