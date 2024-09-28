/**
 * Coat racks!
 * Stores your winter coats
 * Cannot be picked up
 */
/obj/item/coat_rack
	name = "coat rack"
	desc = "A nifty rack for storing your winter clothing."
	icon = 'talestation_modules/icons/objects/coatrackdmi.dmi'
	icon_state = "coat_rack"
	pixel_y = 24
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 1
	item_flags = SLOWS_WHILE_IN_HAND
	pass_flags = NONE

/obj/item/coat_rack/proc/populate_contents()
	return

/obj/item/coat_rack/Initialize(mapload)
	. = ..()
	create_storage(storage_type = /datum/storage/coat_rack)
	populate_contents()
	register_context()

/obj/item/coat_rack/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = "Take a coat"
	return CONTEXTUAL_SCREENTIP_SET

/obj/item/coat_rack/update_overlays()
	. = ..()

	var/obj/item/clothing/suit/hooded/wintercoat/wintercoat = "coat"
	switch(contents.len)
		if(1)
			. += mutable_appearance(icon = initial(icon), icon_state = "[wintercoat]_1")
		if(2)
			. += mutable_appearance(icon = initial(icon), icon_state = "[wintercoat]_2")
		if(3)
			. += mutable_appearance(icon = initial(icon), icon_state = "[wintercoat]_3")
		if(4)
			. += mutable_appearance(icon = initial(icon), icon_state = "[wintercoat]_4")

/obj/item/coat_rack/attack_hand(mob/living/user)
	if(!user.can_perform_action(src, NEED_HANDS))
		return ..()
	if(!length(contents))
		balloon_alert(user, "empty!")
	else
		var/obj/item/grabbies = pick(contents)
		atom_storage.remove_single(user, grabbies, drop_location())
		user.put_in_hands(grabbies)
	return TRUE

/obj/item/coat_rack/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	tool.play_tool_sound(src)
	to_chat(user, span_notice("You begin taking apart [src]."))
	if(!tool.use_tool(src, user, 1 SECONDS))
		return
	deconstruct(TRUE)
	to_chat(user, span_notice("[src] has been taken apart."))

/obj/item/coat_rack/dump_contents()
	var/atom/drop_point = drop_location()
	for(var/atom/movable/tool as anything in contents)
		tool.forceMove(drop_point)

/obj/item/coat_rack/deconstruct(disassembled = TRUE)
	if(!(obj_flags & NO_DECONSTRUCTION))
		dump_contents()
		new /obj/item/stack/sheet/mineral/wood(drop_location(), 5)
	return ..()
