// Tajaran markings
/datum/preference/choiced/tajaran_body_markings
	savefile_key = "feature_tajaran_markings"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_FEATURES
	main_feature_name = "Body markings"
	should_generate_icons = TRUE
	relevant_mutant_bodypart = "tajaran_body_markings"

/datum/preference/choiced/tajaran_body_markings/init_possible_values()
	return assoc_to_keys_features(GLOB.tajaran_body_markings_list)

/datum/preference/choiced/tajaran_body_markings/icon_for(value)
	var/datum/sprite_accessory/sprite_accessory = GLOB.tajaran_body_markings_list[value]

	var/icon/final_icon = icon('talestation_modules/icons/species/tajaran/bodyparts.dmi', "tajaran_chest_m")

	if (sprite_accessory.icon_state != "none")
		var/icon/body_markings_icon = icon(
			'talestation_modules/icons/species/tajaran/tajaran_markings.dmi',
			"m_tajaran_body_markings_[sprite_accessory.icon_state]_ADJ",
		)

		final_icon.Blend(body_markings_icon, ICON_OVERLAY)

	final_icon.Blend(COLOR_WHITE, ICON_MULTIPLY)
	final_icon.Crop(10, 8, 22, 23)
	final_icon.Scale(26, 32)
	final_icon.Crop(-2, 1, 29, 32)

	return final_icon

/datum/preference/choiced/tajaran_body_markings/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_body_markings"] = value

/datum/preference/choiced/tajaran_body_markings/compile_constant_data()
	var/list/data = ..()

	data[SUPPLEMENTAL_FEATURE_KEY] = "tajaran_body_markings_color"

	return data

/datum/bodypart_overlay/mutant/tajaran_body_markings/get_global_feature_list()
	return GLOB.tajaran_body_markings_list

// Tajaran body marking color
/datum/preference/color/tajaran_body_markings_color
	savefile_key = "tajaran_body_markings_color"
	savefile_identifier = PREFERENCE_CHARACTER
	category = PREFERENCE_CATEGORY_SUPPLEMENTAL_FEATURES
	relevant_inherent_trait = TRAIT_MUTANT_COLORS

/datum/preference/color/tajaran_body_markings_color/is_accessible(datum/preferences/preferences)
	if (!..(preferences))
		return FALSE

	var/species_type = preferences.read_preference(/datum/preference/choiced/species)
	var/datum/species/species = new species_type
	return !(TRAIT_FIXED_MUTANT_COLORS in species.inherent_traits)

/datum/preference/color/tajaran_body_markings_color/apply_to_human(mob/living/carbon/human/target, value)
	target.dna.features["tajaran_body_markings_color"] = value

/datum/preference/color/tajaran_body_markings_color/create_default_value()
	return sanitize_hexcolor("[pick("7F", "FF")][pick("7F", "FF")][pick("7F", "FF")]")
