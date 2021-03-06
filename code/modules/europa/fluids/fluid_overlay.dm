/obj/effect/fluid
	name = ""
	icon = 'icons/effects/liquids.dmi'
	anchored = 1
	simulated = 0
	opacity = 0
	mouse_opacity = 0
	layer = FLY_LAYER
	alpha = 0
	color = COLOR_OCEAN

	var/temperature = T20C
	var/fluid_amount = 0     // Declared in stubs/fluid.dm
	var/fluid_type = "water" // Declared in stubs/fluid.dm
	var/turf/start_loc

/obj/effect/fluid/ex_act()
	return

/obj/effect/fluid/airlock_crush()
	qdel(src)

/obj/effect/fluid/proc/lose_fluid(var/amt = 0, var/fluidtype)
	if(amt)
		fluid_amount = max(-1, fluid_amount - amt)
		if(fluid_master)
			fluid_master.add_active_fluid(src)

/obj/effect/fluid/proc/add_fluid(var/amt=-1, var/fluidtype)
	if(fluid_master)
		fluid_master.add_active_fluid(src)

/obj/effect/fluid/proc/set_depth(var/amt=-1)
	fluid_amount = min(FLUID_MAX_DEPTH, amt)
	if(fluid_master)
		fluid_master.add_active_fluid(src)

/obj/effect/fluid/initialize()
	. = ..()
	start_loc = get_turf(src)
	if(!istype(start_loc))
		qdel(src)
		return
	forceMove(start_loc)
	update_icon()

/obj/effect/fluid/Destroy()
	start_loc = null
	if(islist(equalizing_fluids))
		equalizing_fluids.Cut()
	if(fluid_master)
		fluid_master.remove_active_fluid(src)
	return ..()

/obj/effect/fluid/airlock_crush()
	qdel(src)

/obj/effect/fluid_mapped
	name = "mapped flooded area"
	alpha = 125
	icon_state = "shallow_still"
	color = "#66D1FF"
	var/fluid_amount = FLUID_MAX_DEPTH

/obj/effect/fluid_mapped/initialize()
	var/turf/T = get_turf(src)
	if(istype(T))
		var/obj/effect/fluid/F = locate() in T
		if(!F) F = new(T)
		F.set_depth(fluid_amount)
		qdel(src)
