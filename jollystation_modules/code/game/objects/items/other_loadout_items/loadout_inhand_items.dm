/// -- Loadout inhands --
/obj/item/spear/bonespear/ceremonial
	icon_state = "bone_spear0"
	base_icon_state = "bone_spear0"
	icon_prefix = "bone_spear"
	name = "ceremonial bone spear"
	desc = "An old, now-ceremonial spear made of bone and sinew. It's seen better days. While it's hardly any use as a weapon anymore, it still holds a fond place in your heart."
	w_class = WEIGHT_CLASS_NORMAL
	force = 5
	throw_speed = 2
	throwforce = 9
	armour_penetration = 10
	wound_bonus = -20
	bare_wound_bonus = -10
	embedding = list(embed_chance=15, fall_chance=10, jostle_chance=2, ignore_throwspeed_threshold=TRUE, pain_mult=1, jostle_pain_mult=1.2, rip_time=5)

/obj/item/spear/bonespear/ceremonial/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=5, force_wielded=9, icon_wielded="[icon_prefix]1")
