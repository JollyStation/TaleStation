// Modular Light switch bullshit

/obj/machinery/light_switch/interact(mob/user)
	. = ..()
	playsound(src, 'jollystation_modules/sound/machines/lights/lightswitch.ogg', 100, 1)

/obj/machinery/light_switch/LateInitialize()
	. = ..()
	if(prob(50)) //50% chance for an area to have their lights flipped.
		set_lights(!area.lightswitch)
