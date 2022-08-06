// -- Various slime people additions. --
/datum/species/jelly
	species_pain_mod = 0.5
	// Changes the default jellyperson to look like slimepeople instead of stargazers
	// (Because slimepeople are more customizable / less ugly)
	hair_color = "mutcolor"
	hair_alpha = 150
	examine_limb_id = SPECIES_JELLYPERSON

/datum/species/jelly/New()
	. = ..()
	species_traits += list(HAIR, FACEHAIR)

/datum/species/jelly/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features["mcolor"] = sanitize_hexcolor(COLOR_PINK)
	human.hairstyle = "Bob Hair 2"
	human.hair_color = "mutcolor"

	human.update_hair()
	human.update_body()
	human.update_body_parts(update_limb_data = TRUE)
