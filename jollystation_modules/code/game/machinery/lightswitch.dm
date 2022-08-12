// Modular Light switch bullshit

/obj/machinery/light_switch/interact(mob/user)
	. = ..()
	playsound(src, 'jollystation_modules/sound/machines/lights/lightswitch.ogg', 100, 1)

/obj/machinery/light_switch/Initialize(mapload)
	. = ..()
	if(prob(50) && area.lightswitch) //50% chance for area to start with lights off.
		turn_off()

/obj/machinery/light_switch/proc/turn_off()
	if(!area.lightswitch)
		return
	area.lightswitch = FALSE
	area.update_icon()

	for(var/obj/machinery/light_switch/L in area)
		L.update_icon()

	area.power_change()
