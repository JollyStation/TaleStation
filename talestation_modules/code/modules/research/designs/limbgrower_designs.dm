//makes the fox tail printable

/datum/design/foxtail
	name = "Fox Tail"
	id = "foxtail"
	build_type = LIMBGROWER
	reagents_list = list(/datum/reagent/medicine/c2/synthflesh = 20)
	build_path = /obj/item/organ/external/tail/cat/fox
	category = list(RND_CATEGORY_OTHER)

/obj/item/disk/design_disk/limbs/felinid
	limb_designs = list(/datum/design/cat_tail, /datum/design/cat_ears, /datum/design/foxtail)
