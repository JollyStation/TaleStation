/obj/item/organ/internal/lungs
	name = "lungs"
	icon_state = "lungs"
	visual = FALSE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL

	var/respiration_type = NONE // The type(s) of gas this lung needs for respiration

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY * 0.9 // fails around 16.5 minutes, lungs are one of the last organs to die (of the ones we have)

	low_threshold_passed = "<span class='warning'>You feel short of breath.</span>"
	high_threshold_passed = "<span class='warning'>You feel some sort of constriction around your chest as your breathing becomes shallow and rapid.</span>"
	now_fixed = "<span class='warning'>Your lungs seem to once again be able to hold air.</span>"
	low_threshold_cleared = "<span class='info'>You can breathe normally again.</span>"
	high_threshold_cleared = "<span class='info'>The constriction around your chest loosens as your breathing calms down.</span>"

	var/failed = FALSE
	var/operated = FALSE //whether we can still have our damages fixed through surgery


	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/medicine/salbutamol = 5)

<<<<<<< HEAD
=======
	/// Our previous breath's partial pressures, in the form gas id -> partial pressure
	var/list/last_partial_pressures = list()
	/// List of gas to treat as other gas, in the form list(inital_gas, treat_as, multiplier)
	var/list/treat_as = list()
	/// Assoc list of procs to run while a gas is present, in the form gas id -> proc_path
	var/list/breath_present = list()
	/// Assoc list of procs to run when a gas is immediately removed from the breath, in the form gas id -> proc_path
	var/list/breath_lost = list()
	/// Assoc list of procs to always run, in the form gas_id -> proc_path
	var/list/breathe_always = list()

	/// Gas mixture to breath out when we're done processing a breath
	/// Will get emptied out when it's all done
	var/datum/gas_mixture/immutable/breath_out

>>>>>>> a773c346beda4 (Fixes ploux, adds conversion support to breath code (#74316))
	//Breath damage
	//These thresholds are checked against what amounts to total_mix_pressure * (gas_type_mols/total_mols)
	var/safe_oxygen_min = 16 // Minimum safe partial pressure of O2, in kPa
	var/safe_oxygen_max = 0
	var/safe_nitro_min = 0
	var/safe_nitro_max = 0
	var/safe_co2_min = 0
	var/safe_co2_max = 10 // Yes it's an arbitrary value who cares?
	var/safe_plasma_min = 0
	///How much breath partial pressure is a safe amount of plasma. 0 means that we are immune to plasma.
	var/safe_plasma_max = 0.05
	var/n2o_para_min = 1 //Sleeping agent
	var/n2o_sleep_min = 5 //Sleeping agent
	var/BZ_trip_balls_min = 1 //BZ gas
	var/BZ_brain_damage_min = 10 //Give people some room to play around without killing the station
	var/gas_stimulation_min = 0.002 // For, Pluoxium, Nitrium and Freon
	///Minimum amount of healium to make you unconscious for 4 seconds
	var/healium_para_min = 3
	///Minimum amount of healium to knock you down for good
	var/healium_sleep_min = 6
	///Minimum amount of helium to affect speech
	var/helium_speech_min = 5
	//Whether helium speech effects are currently active
	var/helium_speech = FALSE
	///Whether these lungs react negatively to miasma
	var/suffers_miasma = TRUE

	var/oxy_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/oxy_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/oxy_damage_type = OXY
	var/nitro_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/nitro_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/nitro_damage_type = OXY
	var/co2_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/co2_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/co2_damage_type = OXY
	var/plas_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/plas_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/plas_damage_type = TOX

	var/tritium_irradiation_moles_min = 1
	var/tritium_irradiation_moles_max = 15
	var/tritium_irradiation_probability_min = 10
	var/tritium_irradiation_probability_max = 60

	var/cold_message = "your face freezing and an icicle forming"
	var/cold_level_1_threshold = 260
	var/cold_level_2_threshold = 200
	var/cold_level_3_threshold = 120
	var/cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_1 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	var/cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_2
	var/cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_3
	var/cold_damage_type = BURN

	var/hot_message = "your face burning and a searing heat"
	var/heat_level_1_threshold = 360
	var/heat_level_2_threshold = 400
	var/heat_level_3_threshold = 1000
	var/heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_1
	var/heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_2
	var/heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	var/heat_damage_type = BURN

	var/crit_stabilizing_reagent = /datum/reagent/medicine/epinephrine

// assign the respiration_type
/obj/item/organ/internal/lungs/Initialize(mapload)
	. = ..()

	if(safe_co2_min)
		respiration_type |= RESPIRATION_CO2
	if(safe_nitro_min)
		respiration_type |= RESPIRATION_N2
	if(safe_oxygen_min)
		respiration_type |= RESPIRATION_OXYGEN
	if(safe_plasma_min)
		respiration_type |= RESPIRATION_PLASMA

<<<<<<< HEAD
=======
	// Sets up what gases we want to react to, and in what way
	// always is always processed, while_present is called when the gas is in the breath, and on_loss is called right after a gas is lost
	// The naming convention goes like this
	// always : breath_{gas_type}
	// safe/neutral while_present : consume_{gas_type}
	// safe/neutral on_loss : lose_{gas_type}
	// dangerous while_present : too_much_{gas_type}
	// dangerous on_loss : safe_{gas_type}
	// These are reccomendations, if something seems better feel free to ignore them. S a bit vibes based
	if(safe_oxygen_min)
		add_gas_reaction(/datum/gas/oxygen, always = PROC_REF(breathe_oxygen))
	if(safe_oxygen_max)
		add_gas_reaction(/datum/gas/oxygen, while_present = PROC_REF(too_much_oxygen), on_loss = PROC_REF(safe_oxygen))
	add_gas_reaction(/datum/gas/pluoxium, while_present = PROC_REF(consume_pluoxium))
	// We treat a mole of ploux as 8 moles of oxygen
	add_gas_relationship(/datum/gas/pluoxium, /datum/gas/oxygen, 8)
	if(safe_nitro_min)
		add_gas_reaction(/datum/gas/nitrogen, always = PROC_REF(breathe_nitro))
	if(safe_co2_max)
		add_gas_reaction(/datum/gas/carbon_dioxide, while_present = PROC_REF(too_much_co2), on_loss = PROC_REF(safe_co2))
	if(safe_plasma_min)
		add_gas_reaction(/datum/gas/plasma, always = PROC_REF(breathe_plasma))
	if(safe_plasma_max)
		add_gas_reaction(/datum/gas/plasma, while_present = PROC_REF(too_much_plasma), on_loss = PROC_REF(safe_plasma))
	add_gas_reaction(/datum/gas/bz, while_present = PROC_REF(too_much_bz))
	add_gas_reaction(/datum/gas/freon, while_present = PROC_REF(too_much_freon))
	add_gas_reaction(/datum/gas/halon, while_present = PROC_REF(too_much_halon))
	add_gas_reaction(/datum/gas/healium, while_present = PROC_REF(consume_healium), on_loss = PROC_REF(lose_healium))
	add_gas_reaction(/datum/gas/helium, while_present = PROC_REF(consume_helium), on_loss = PROC_REF(lose_helium))
	add_gas_reaction(/datum/gas/hypernoblium, while_present = PROC_REF(consume_hypernoblium))
	if(suffers_miasma)
		add_gas_reaction(/datum/gas/miasma, while_present = PROC_REF(too_much_miasma), on_loss = PROC_REF(safe_miasma))
	add_gas_reaction(/datum/gas/nitrous_oxide, while_present = PROC_REF(too_much_n2o), on_loss = PROC_REF(safe_n2o))
	add_gas_reaction(/datum/gas/nitrium, while_present = PROC_REF(too_much_nitrium))
	add_gas_reaction(/datum/gas/tritium, while_present = PROC_REF(too_much_tritium))
	add_gas_reaction(/datum/gas/zauker, while_present = PROC_REF(too_much_zauker))

>>>>>>> a773c346beda4 (Fixes ploux, adds conversion support to breath code (#74316))
///Simply exists so that you don't keep any alerts from your previous lack of lungs.
/obj/item/organ/internal/lungs/Insert(mob/living/carbon/receiver, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(!.)
		return .
	receiver.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
	receiver.clear_alert(ALERT_NOT_ENOUGH_CO2)
	receiver.clear_alert(ALERT_NOT_ENOUGH_NITRO)
	receiver.clear_alert(ALERT_NOT_ENOUGH_PLASMA)
	receiver.clear_alert(ALERT_NOT_ENOUGH_N2O)

<<<<<<< HEAD
=======
/obj/item/organ/internal/lungs/Remove(mob/living/carbon/organ_owner, special)
	. = ..()
	// This is very "manual" I realize, but it's useful to ensure cleanup for gases we're removing happens
	// Avoids stuck alerts and such
	var/static/datum/gas_mixture/immutable/dummy = new(BREATH_VOLUME)
	for(var/gas_id in last_partial_pressures)
		var/on_loss = breath_lost[gas_id]
		if(!on_loss)
			continue

		call(src, on_loss)(organ_owner, dummy, last_partial_pressures[gas_id])
	dummy.garbage_collect()

/**
 * Tells the lungs to pay attention to the passed in gas type
 * We'll check for it when breathing, in a few possible ways
 * Accepts 3 optional arguments:
 *
 * proc/while_present * Called while the gas is present in our breath. Return BREATH_LOST to call on_loss afterwards
 * proc/on_loss * Called after we have lost a gas from our breath.
 * proc/always * Always called. Best suited for breathing procs, like oxygen
 *
 * while_present and always get the same arguments (mob/living/carbon/breather, datum/gas_mixture/breath, pp, old_pp)
 * on_loss is almost exactly the same, except it doesn't pass in a current partial pressure, since one isn't avalible
 */
/obj/item/organ/internal/lungs/proc/add_gas_reaction(gas_type, while_present = null, on_loss = null, always = null)
	if(always)
		breathe_always[gas_type] = always

	if(isnull(while_present) && isnull(on_loss))
		return

	if(while_present)
		breath_present[gas_type] = while_present
	if(on_loss)
		breath_lost[gas_type] = on_loss

#define BREATH_RELATIONSHIP_INITIAL_GAS 1
#define BREATH_RELATIONSHIP_CONVERT 2
#define BREATH_RELATIONSHIP_MULTIPLIER 3
/**
 * Tells the lungs to treat the passed in gas type as another passed in gas type
 * Takes the gas to check for as an argument, alongside the gas to convert and the multiplier to use
 * These act in the order of insertion, use that how you will
 */
/obj/item/organ/internal/lungs/proc/add_gas_relationship(gas_type, convert_to, multiplier)
	if(isnull(gas_type) || isnull(convert_to) || multiplier == 0)
		return

	var/list/add = new /list(BREATH_RELATIONSHIP_MULTIPLIER)
	add[BREATH_RELATIONSHIP_INITIAL_GAS] = gas_type
	add[BREATH_RELATIONSHIP_CONVERT] = convert_to
	add[BREATH_RELATIONSHIP_MULTIPLIER] = multiplier
	treat_as += list(add)

/// Clears away a gas relationship. Takes the same args as the initial addition
/obj/item/organ/internal/lungs/proc/remove_gas_relationship(gas_type, convert_to, multiplier)
	if(isnull(gas_type) || isnull(convert_to) || multiplier == 0)
		return

	for(var/packet in treat_as)
		if(packet[BREATH_RELATIONSHIP_INITIAL_GAS] != gas_type)
			continue
		if(packet[BREATH_RELATIONSHIP_CONVERT] != convert_to)
			continue
		if(packet[BREATH_RELATIONSHIP_MULTIPLIER] != multiplier)
			continue
		treat_as -= packet
		return

/// Handles oxygen breathing. Always called by things that need o2, no matter what
/obj/item/organ/internal/lungs/proc/breathe_oxygen(mob/living/carbon/breather, datum/gas_mixture/breath, o2_pp, old_o2_pp)
	if(o2_pp < safe_oxygen_min && !HAS_TRAIT(src, TRAIT_SPACEBREATHING))
		// Not safe to check the old pp because of can_breath_vacuum
		breather.throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)

		var/gas_breathed = handle_suffocation(breather, o2_pp, safe_oxygen_min, breath.gases[/datum/gas/oxygen][MOLES])
		if(o2_pp)
			breathe_gas_volume(breath, /datum/gas/oxygen, /datum/gas/carbon_dioxide, volume = gas_breathed)
		return

	// If we used to not have enough, clear the alert
	// Note this can be redundant, because of the vacuum check. It is fail safe tho, so it's ok
	if(old_o2_pp < safe_oxygen_min)
		breather.failed_last_breath = FALSE
		breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)

	breathe_gas_volume(breath, /datum/gas/oxygen, /datum/gas/carbon_dioxide)
	// Heal mob if not in crit.
	if(breather.health >= breather.crit_threshold && breather.oxyloss)
		breather.adjustOxyLoss(-5)

/// Maximum Oxygen effects. "Too much O2!"
/obj/item/organ/internal/lungs/proc/too_much_oxygen(mob/living/carbon/breather, datum/gas_mixture/breath, o2_pp, old_o2_pp)
	// If too much Oxygen is poisonous.
	if(o2_pp <= safe_oxygen_max)
		if(old_o2_pp > safe_oxygen_max)
			return BREATH_LOST
		return

	var/ratio = (breath.gases[/datum/gas/oxygen][MOLES] / safe_oxygen_max) * 10
	breather.apply_damage_type(clamp(ratio, oxy_breath_dam_min, oxy_breath_dam_max), oxy_damage_type)
	breather.throw_alert(ALERT_TOO_MUCH_OXYGEN, /atom/movable/screen/alert/too_much_oxy)

/// Handles NOT having too much o2. only relevant if safe_oxygen_max has a value
/obj/item/organ/internal/lungs/proc/safe_oxygen(mob/living/carbon/breather, datum/gas_mixture/breath, old_o2_pp)
	breather.clear_alert(ALERT_TOO_MUCH_OXYGEN)

/// Behaves like Oxygen with 8X efficacy, but metabolizes into a reagent.
/obj/item/organ/internal/lungs/proc/consume_pluoxium(mob/living/carbon/breather, datum/gas_mixture/breath, pluoxium_pp, old_pluoxium_pp)
	breathe_gas_volume(breath, /datum/gas/pluoxium)
	// Metabolize to reagent.
	if(pluoxium_pp > gas_stimulation_min)
		var/existing = breather.reagents.get_reagent_amount(/datum/reagent/pluoxium)
		breather.reagents.add_reagent(/datum/reagent/pluoxium, max(0, 1 - existing))

/// If the lungs need Nitrogen to breathe properly, N2 is exchanged with CO2.
/obj/item/organ/internal/lungs/proc/breathe_nitro(mob/living/carbon/breather, datum/gas_mixture/breath, nitro_pp, old_nitro_pp)
	if(nitro_pp < safe_nitro_min && !HAS_TRAIT(src, TRAIT_SPACEBREATHING))
		// Suffocation side-effects.
		// Not safe to check the old pp because of can_breath_vacuum
		breather.throw_alert(ALERT_NOT_ENOUGH_NITRO, /atom/movable/screen/alert/not_enough_nitro)
		var/gas_breathed = handle_suffocation(breather, nitro_pp, safe_nitro_min, breath.gases[/datum/gas/nitrogen][MOLES])
		if(nitro_pp)
			breathe_gas_volume(breath, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, volume = gas_breathed)
		return

	if(old_nitro_pp < safe_nitro_min)
		breather.failed_last_breath = FALSE
		breather.clear_alert(ALERT_NOT_ENOUGH_NITRO)

	// Inhale N2, exhale equivalent amount of CO2. Look ma, sideways breathing!
	breathe_gas_volume(breath, /datum/gas/nitrogen, /datum/gas/carbon_dioxide)
	// Heal mob if not in crit.
	if(breather.health >= breather.crit_threshold && breather.oxyloss)
		breather.adjustOxyLoss(-5)

/// Maximum CO2 effects. "Too much CO2!"
/obj/item/organ/internal/lungs/proc/too_much_co2(mob/living/carbon/breather, datum/gas_mixture/breath, co2_pp, old_co2_pp)
	if(co2_pp <= safe_co2_max)
		if(old_co2_pp > safe_co2_max)
			return BREATH_LOST
		return

	// If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
	if(old_co2_pp < safe_co2_max)
		breather.co2overloadtime = world.time

	// CO2 side-effects.
	// Give the mob a chance to notice.
	if(prob(20))
		breather.emote("cough")

	if((world.time - breather.co2overloadtime) > 12 SECONDS)
		breather.throw_alert(ALERT_TOO_MUCH_CO2, /atom/movable/screen/alert/too_much_co2)
		breather.Unconscious(6 SECONDS)
		// Lets hurt em a little, let them know we mean business.
		breather.apply_damage_type(3, co2_damage_type)
		// They've been in here 30s now, start to kill them for their own good!
		if((world.time - breather.co2overloadtime) > 30 SECONDS)
			breather.apply_damage_type(8, co2_damage_type)

/// Handles NOT having too much co2. only relevant if safe_co2_max has a value
/obj/item/organ/internal/lungs/proc/safe_co2(mob/living/carbon/breather, datum/gas_mixture/breath, old_co2_pp)
	// Reset side-effects.
	breather.co2overloadtime = 0
	breather.clear_alert(ALERT_TOO_MUCH_CO2)

/// If the lungs need Plasma to breathe properly, Plasma is exchanged with CO2.
/obj/item/organ/internal/lungs/proc/breathe_plasma(mob/living/carbon/breather, datum/gas_mixture/breath, plasma_pp, old_plasma_pp)
	// Suffocation side-effects.
	if(plasma_pp < safe_plasma_min && !HAS_TRAIT(src, TRAIT_SPACEBREATHING))
		// Could check old_plasma_pp but vacuum breathing hates me
		breather.throw_alert(ALERT_NOT_ENOUGH_PLASMA, /atom/movable/screen/alert/not_enough_plas)
		// Breathe insufficient amount of Plasma, exhale CO2.
		var/gas_breathed = handle_suffocation(breather, plasma_pp, safe_plasma_min, breath.gases[/datum/gas/plasma][MOLES])
		if(plasma_pp)
			breathe_gas_volume(breath, /datum/gas/plasma, /datum/gas/carbon_dioxide, volume = gas_breathed)
		return

	if(old_plasma_pp < safe_plasma_min)
		breather.failed_last_breath = FALSE
		breather.clear_alert(ALERT_NOT_ENOUGH_PLASMA)
	// Inhale Plasma, exhale equivalent amount of CO2.
	breathe_gas_volume(breath, /datum/gas/plasma, /datum/gas/carbon_dioxide)
	// Heal mob if not in crit.
	if(breather.health >= breather.crit_threshold && breather.oxyloss)
		breather.adjustOxyLoss(-5)

/// Maximum Plasma effects. "Too much Plasma!"
/obj/item/organ/internal/lungs/proc/too_much_plasma(mob/living/carbon/breather, datum/gas_mixture/breath, plasma_pp, old_plasma_pp)
	if(plasma_pp <= safe_plasma_max)
		if(old_plasma_pp > safe_plasma_max)
			return BREATH_LOST
		return

	// If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
	if(old_plasma_pp < safe_plasma_max)
		breather.throw_alert(ALERT_TOO_MUCH_PLASMA, /atom/movable/screen/alert/too_much_plas)

	var/ratio = (breath.gases[/datum/gas/plasma][MOLES] / safe_plasma_max) * 10
	breather.apply_damage_type(clamp(ratio, plas_breath_dam_min, plas_breath_dam_max), plas_damage_type)

/// Resets plasma side effects
/obj/item/organ/internal/lungs/proc/safe_plasma(mob/living/carbon/breather, datum/gas_mixture/breath, old_plasma_pp)
	breather.clear_alert(ALERT_TOO_MUCH_PLASMA)

/// Too much funny gas, time to get brain damage
/obj/item/organ/internal/lungs/proc/too_much_bz(mob/living/carbon/breather, datum/gas_mixture/breath, bz_pp, old_bz_pp)
	if(bz_pp > BZ_trip_balls_min)
		breather.adjust_hallucinations(20 SECONDS)
		breather.reagents.add_reagent(/datum/reagent/bz_metabolites, 5)
	if(bz_pp > BZ_brain_damage_min && prob(33))
		breather.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150, ORGAN_ORGANIC)

/// Breathing in refridgerator coolent, shit's caustic
/obj/item/organ/internal/lungs/proc/too_much_freon(mob/living/carbon/breather, datum/gas_mixture/breath, freon_pp, old_freon_pp)
	// Inhale Freon. Exhale nothing.
	breathe_gas_volume(breath, /datum/gas/freon)
	if (freon_pp > gas_stimulation_min)
		breather.reagents.add_reagent(/datum/reagent/freon, 1)
	if (prob(freon_pp))
		to_chat(breather, span_alert("Your mouth feels like it's burning!"))
	if (freon_pp > 40)
		breather.emote("gasp")
		breather.adjustFireLoss(15)
		if (prob(freon_pp / 2))
			to_chat(breather, span_alert("Your throat closes up!"))
			breather.set_silence_if_lower(6 SECONDS)
	else
		breather.adjustFireLoss(freon_pp / 4)

/// Breathing in halon, convert it to a reagent
/obj/item/organ/internal/lungs/proc/too_much_halon(mob/living/carbon/breather, datum/gas_mixture/breath, halon_pp, old_halon_pp)
	// Inhale Halon. Exhale nothing.
	breathe_gas_volume(breath, /datum/gas/halon)
	// Metabolize to reagent.
	if(halon_pp > gas_stimulation_min)
		breather.adjustOxyLoss(5)
		breather.reagents.add_reagent(/datum/reagent/halon, max(0, 1 - breather.reagents.get_reagent_amount(/datum/reagent/halon)))

/// Sleeping gas with healing properties.
/obj/item/organ/internal/lungs/proc/consume_healium(mob/living/carbon/breather, datum/gas_mixture/breath, healium_pp, old_healium_pp)
	breathe_gas_volume(breath, /datum/gas/healium)
	// Euphoria side-effect.
	if(healium_pp > gas_stimulation_min)
		if(prob(15))
			to_chat(breather, span_alert("Your head starts spinning and your lungs burn!"))
			healium_euphoria = EUPHORIA_ACTIVE
			breather.emote("gasp")
	else
		healium_euphoria = EUPHORIA_INACTIVE
	// Stun/Sleep side-effects.
	if(healium_pp > healium_para_min)
		// Random chance to stun mob. Timing not in seconds to have a much higher variation
		breather.Unconscious(rand(3 SECONDS, 5 SECONDS))
	// Metabolize to reagent when concentration is high enough.
	if(healium_pp > healium_sleep_min)
		breather.reagents.add_reagent(/datum/reagent/healium, max(0, 1 - breather.reagents.get_reagent_amount(/datum/reagent/healium)))

/// Lose healium side effects
/obj/item/organ/internal/lungs/proc/lose_healium(mob/living/carbon/breather, datum/gas_mixture/breath, old_healium_pp)
	healium_euphoria = EUPHORIA_INACTIVE

/// Activates helium speech when partial pressure gets high enough
/obj/item/organ/internal/lungs/proc/consume_helium(mob/living/carbon/breather, datum/gas_mixture/breath, helium_pp, old_helium_pp)
	breathe_gas_volume(breath, /datum/gas/helium)
	if(helium_pp > helium_speech_min)
		if(old_helium_pp <= helium_speech_min)
			RegisterSignal(breather, COMSIG_MOB_SAY, PROC_REF(handle_helium_speech))
	else
		if(old_helium_pp > helium_speech_min)
			UnregisterSignal(breather, COMSIG_MOB_SAY)

/// Lose helium high pitched voice
/obj/item/organ/internal/lungs/proc/lose_helium(mob/living/carbon/breather, datum/gas_mixture/breath, old_helium_pp)
	UnregisterSignal(breather, COMSIG_MOB_SAY)

/// React to speach while hopped up on the high pitched voice juice
/obj/item/organ/internal/lungs/proc/handle_helium_speech(mob/living/carbon/breather, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= SPAN_HELIUM

/// Gain hypernob effects if we have enough of the stuff
/obj/item/organ/internal/lungs/proc/consume_hypernoblium(mob/living/carbon/breather, datum/gas_mixture/breath, hypernob_pp, old_hypernob_pp)
	breathe_gas_volume(breath, /datum/gas/hypernoblium)
	if (hypernob_pp > gas_stimulation_min)
		var/existing = breather.reagents.get_reagent_amount(/datum/reagent/hypernoblium)
		breather.reagents.add_reagent(/datum/reagent/hypernoblium,max(0, 1 - existing))

/// Breathing in the stink gas
/obj/item/organ/internal/lungs/proc/too_much_miasma(mob/living/carbon/breather, datum/gas_mixture/breath, miasma_pp, old_miasma_pp)
	// Inhale Miasma. Exhale nothing.
	breathe_gas_volume(breath, /datum/gas/miasma)
	// Miasma sickness
	if(prob(0.5 * miasma_pp))
		var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(max_symptoms = min(round(max(miasma_pp / 2, 1), 1), 6), max_level = min(round(max(miasma_pp, 1), 1), 8))
		// tl;dr the first argument chooses the smaller of miasma_pp/2 or 6(typical max virus symptoms), the second chooses the smaller of miasma_pp or 8(max virus symptom level)
		// Each argument has a minimum of 1 and rounds to the nearest value. Feel free to change the pp scaling I couldn't decide on good numbers for it.
		miasma_disease.name = "Unknown"
		miasma_disease.try_infect(breather)
	// Miasma side effects
	switch(miasma_pp)
		if(0.25 to 5)
			// At lower pp, give out a little warning
			breather.clear_mood_event("smell")
			if(prob(5))
				to_chat(breather, span_notice("There is an unpleasant smell in the air."))
		if(5 to 15)
			//At somewhat higher pp, warning becomes more obvious
			if(prob(15))
				to_chat(breather, span_warning("You smell something horribly decayed inside this room."))
				breather.add_mood_event("smell", /datum/mood_event/disgust/bad_smell)
		if(15 to 30)
			//Small chance to vomit. By now, people have internals on anyway
			if(prob(5))
				to_chat(breather, span_warning("The stench of rotting carcasses is unbearable!"))
				breather.add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
				breather.vomit()
		if(30 to INFINITY)
			//Higher chance to vomit. Let the horror start
			if(prob(15))
				to_chat(breather, span_warning("The stench of rotting carcasses is unbearable!"))
				breather.add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
				breather.vomit()
		else
			breather.clear_mood_event("smell")
	// In a full miasma atmosphere with 101.34 pKa, about 10 disgust per breath, is pretty low compared to threshholds
	// Then again, this is a purely hypothetical scenario and hardly reachable
	breather.adjust_disgust(0.1 * miasma_pp)

/// We're free from the stick, clear out its impacts
/obj/item/organ/internal/lungs/proc/safe_miasma(mob/living/carbon/breather, datum/gas_mixture/breath, old_miasma_pp)
	// Clear out moods when immune to miasma, or if there's no miasma at all.
	breather.clear_mood_event("smell")

/// Causes random euphoria and giggling. Large amounts knock you down
/obj/item/organ/internal/lungs/proc/too_much_n2o(mob/living/carbon/breather, datum/gas_mixture/breath, n2o_pp, old_n2o_pp)
	if(n2o_pp < n2o_para_min)
		// Small amount of N2O, small side-effects.
		if(n2o_pp <= 0.01)
			if(old_n2o_pp > 0.01)
				return BREATH_LOST
			return
		// No alert for small amounts, but the mob randomly feels euphoric.
		if(old_n2o_pp >= n2o_para_min || old_n2o_pp <= 0.01)
			breather.clear_alert(ALERT_TOO_MUCH_N2O)

		if(prob(20))
			n2o_euphoria = EUPHORIA_ACTIVE
			breather.emote(pick("giggle", "laugh"))
		else
			n2o_euphoria = EUPHORIA_INACTIVE
		return

	// More N2O, more severe side-effects. Causes stun/sleep.
	if(old_n2o_pp < n2o_para_min)
		breather.throw_alert(ALERT_TOO_MUCH_N2O, /atom/movable/screen/alert/too_much_n2o)
	n2o_euphoria = EUPHORIA_ACTIVE

	// give them one second of grace to wake up and run away a bit!
	breather.Unconscious(6 SECONDS)
	// Enough to make the mob sleep.
	if(n2o_pp > n2o_sleep_min)
		breather.Sleeping(min(breather.AmountSleeping() + 100, 200))

/// N2O side-effects. "Too much N2O!"
/obj/item/organ/internal/lungs/proc/safe_n2o(mob/living/carbon/breather, datum/gas_mixture/breath, old_n2o_pp)
	n2o_euphoria = EUPHORIA_INACTIVE
	breather.clear_alert(ALERT_TOO_MUCH_N2O)

// Breath in nitrium. It's helpful, but has nasty side effects
/obj/item/organ/internal/lungs/proc/too_much_nitrium(mob/living/carbon/breather, datum/gas_mixture/breath, nitrium_pp, old_nitrium_pp)
	breathe_gas_volume(breath, /datum/gas/nitrium)
	// Random chance to inflict side effects increases with pressure.
	if((prob(nitrium_pp) && (nitrium_pp > 15)))
		// Nitrium side-effect.
		breather.adjustOrganLoss(ORGAN_SLOT_LUNGS, nitrium_pp * 0.1)
		to_chat(breather, "<span class='notice'>You feel a burning sensation in your chest</span>")
	// Metabolize to reagents.
	if (nitrium_pp > 5)
		var/existing = breather.reagents.get_reagent_amount(/datum/reagent/nitrium_low_metabolization)
		breather.reagents.add_reagent(/datum/reagent/nitrium_low_metabolization, max(0, 2 - existing))
	if (nitrium_pp > 10)
		var/existing = breather.reagents.get_reagent_amount(/datum/reagent/nitrium_high_metabolization)
		breather.reagents.add_reagent(/datum/reagent/nitrium_high_metabolization, max(0, 1 - existing))

/// Radioactive, green gas. Toxin damage, and a radiation chance
/obj/item/organ/internal/lungs/proc/too_much_tritium(mob/living/carbon/breather, datum/gas_mixture/breath, trit_pp, old_trit_pp)
	var/gas_breathed = breathe_gas_volume(breath, /datum/gas/tritium)
	// Tritium side-effects.
	var/ratio = gas_breathed * 15
	breather.adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
	// If you're breathing in half an atmosphere of radioactive gas, you fucked up.
	if((trit_pp > tritium_irradiation_moles_min) && SSradiation.can_irradiate_basic(breather))
		var/lerp_scale = min(tritium_irradiation_moles_max, trit_pp - tritium_irradiation_moles_min) / (tritium_irradiation_moles_max - tritium_irradiation_moles_min)
		var/chance = LERP(tritium_irradiation_probability_min, tritium_irradiation_probability_max, lerp_scale)
		if (prob(chance))
			breather.AddComponent(/datum/component/irradiated)

/// Really toxic stuff, very much trying to kill you
/obj/item/organ/internal/lungs/proc/too_much_zauker(mob/living/carbon/breather, datum/gas_mixture/breath, zauker_pp, old_zauker_pp)
	breathe_gas_volume(breath, /datum/gas/zauker)
	// Metabolize to reagent.
	if(zauker_pp > gas_stimulation_min)
		var/existing = breather.reagents.get_reagent_amount(/datum/reagent/zauker)
		breather.reagents.add_reagent(/datum/reagent/zauker, max(0, 1 - existing))

>>>>>>> a773c346beda4 (Fixes ploux, adds conversion support to breath code (#74316))
/**
 * This proc tests if the lungs can breathe, if they can breathe a given gas mixture, and throws/clears gas alerts.
 * If there are moles of gas in the given gas mixture, side-effects may be applied/removed on the mob.
 * If a required gas (such as Oxygen) is missing from the breath, then it calls [proc/handle_suffocation].
 *
 * Returns TRUE if the breath was successful, or FALSE if otherwise.
 *
 * Arguments:
 * * breath: A gas mixture to test, or null.
 * * breather: A carbon mob that is using the lungs to breathe.
 */
/obj/item/organ/internal/lungs/proc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/breather)
	if(breather.status_flags & GODMODE)
		breather.failed_last_breath = FALSE
		breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
		return

	if(HAS_TRAIT(breather, TRAIT_NOBREATH))
		return

	/// Immutable "empty breath" used to store waste gases before they are re-added to the main breath.
	/// empty_breath is also used as a backup for breath if it was null.
	/// During gas exchange each output gas is temporarily transferred into this gas_mixture, and then transferred back into the breath.
	/// Two gas_mixtures are used because we don't want exchanges to influence each other.
	var/static/datum/gas_mixture/immutable/empty_breath = new(BREATH_VOLUME)
	var/datum/gas_mixture/immutable/breath_out = empty_breath

	// If the breath is falsy or "null", we can use the backup empty_breath.
	if(!breath)
		breath = empty_breath

	// Ensure gas volumes are present.
	for(var/gas_id in GLOB.meta_gas_info)
		breath.assert_gas(gas_id)

	// Indicates if there are moles of gas in the breath.
	var/has_moles = breath.total_moles() != 0

	/// List of gases to be inhaled.
	var/list/breath_gases = breath.gases
	/// List of gases to be exhaled.
	var/list/breath_gases_out = breath_out.gases

	// Indicates if lungs can breathe without gas.
	var/can_breathe_vacuum = HAS_TRAIT(src, TRAIT_SPACEBREATHING)
	// Vars for N2O/healium induced euphoria, stun, and sleep.
	var/n2o_euphoria = EUPHORIA_LAST_FLAG
	var/healium_euphoria = EUPHORIA_LAST_FLAG

	// Re-usable var used to remove a limited volume of each gas from the given gas mixture.
	var/gas_breathed = 0
	// Partial pressures in the breath.
	// Main Gases
	var/pluoxium_pp = 0
	var/o2_pp = 0
	var/n2_pp = 0
	var/co2_pp = 0
	var/plasma_pp = 0
	// Trace Gases, ordered alphabetically.
	var/bz_pp = 0
	var/freon_pp = 0
	var/healium_pp = 0
	var/helium_pp = 0
	var/halon_pp = 0
	var/hypernob_pp = 0
	var/miasma_pp = 0
	var/n2o_pp = 0
	var/nitrium_pp = 0
	var/trit_pp = 0
	var/zauker_pp = 0

	// Check for moles of gas and handle partial pressures / special conditions.
	if(has_moles)
		// Breath has more than 0 moles of gas.
		// Route gases through mask filter if breather is wearing one.
		if(istype(breather.wear_mask) && (breather.wear_mask.clothing_flags & GAS_FILTERING) && breather.wear_mask.has_filter)
			breath = breather.wear_mask.consume_filter(breath)
			// Idiot-proofing for filter implementation, in case someone swaps the entire gas_mixture.
			breath_gases = breath.gases
		// Partial pressures of "main" gases.
		pluoxium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/pluoxium][MOLES])
		o2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/oxygen][MOLES]) + (8 * pluoxium_pp)
		n2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrogen][MOLES])
		co2_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/carbon_dioxide][MOLES])
		plasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/plasma][MOLES])
		// Partial pressures of "trace" gases.
		bz_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/bz][MOLES])
		freon_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/freon][MOLES])
		halon_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/halon][MOLES])
		healium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/healium][MOLES])
		helium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/helium][MOLES])
		hypernob_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/hypernoblium][MOLES])
		miasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/miasma][MOLES])
		n2o_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrous_oxide][MOLES])
		nitrium_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrium][MOLES])
		trit_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/tritium][MOLES])
		zauker_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/zauker][MOLES])

	// Breath has 0 moles of gas.
	else if(can_breathe_vacuum)
		// The lungs can breathe anyways. What are you? Some bottom-feeding, scum-sucking algae eater?
		breather.failed_last_breath = FALSE
		// Vacuum-adapted lungs regenerate oxyloss even when breathing nothing.
		if(breather.health >= breather.crit_threshold)
			breather.adjustOxyLoss(-5)
	else
		// Can't breathe!
		breather.failed_last_breath = TRUE

	// Handle subtypes' breath processing
	handle_gas_override(breather, breath_gases, 0)

	//-- MAIN GASES --//

	//-- PLUOXIUM --//
	// Behaves like Oxygen with 8X efficacy, but metabolizes into a reagent.
	if(pluoxium_pp)
		// Inhale Pluoxium. Exhale nothing.
		breathe_gas_volume(breath, /datum/gas/pluoxium)
		// Metabolize to reagent.
		if(pluoxium_pp > gas_stimulation_min)
			var/existing = breather.reagents.get_reagent_amount(/datum/reagent/pluoxium)
			breather.reagents.add_reagent(/datum/reagent/pluoxium, max(0, 1 - existing))

	//-- OXYGEN --//
	// Maximum Oxygen effects. "Too much O2!"
	// If too much Oxygen is poisonous.
	if(safe_oxygen_max)
		if(o2_pp && (o2_pp > safe_oxygen_max))
			// O2 side-effects.
			var/ratio = (breath_gases[/datum/gas/oxygen][MOLES] / safe_oxygen_max) * 10
			breather.apply_damage_type(clamp(ratio, oxy_breath_dam_min, oxy_breath_dam_max), oxy_damage_type)
			breather.throw_alert(ALERT_TOO_MUCH_OXYGEN, /atom/movable/screen/alert/too_much_oxy)
		else
			// Reset side-effects.
			breather.clear_alert(ALERT_TOO_MUCH_OXYGEN)

<<<<<<< HEAD
	// Minimum Oxygen effects.
	// If the lungs need Oxygen to breathe properly, O2 is exchanged with CO2.
	if(safe_oxygen_min)
		// Suffocation side-effects.
		if(!can_breathe_vacuum && (o2_pp < safe_oxygen_min))
			breather.throw_alert(ALERT_NOT_ENOUGH_OXYGEN, /atom/movable/screen/alert/not_enough_oxy)
			// Inhale insufficient amount of O2, exhale CO2.
			if(o2_pp)
				gas_breathed = handle_suffocation(breather, o2_pp, safe_oxygen_min, breath_gases[/datum/gas/oxygen][MOLES])
				breathe_gas_volume(breath, /datum/gas/oxygen, /datum/gas/carbon_dioxide, breath_out, volume = gas_breathed)
			else
				// No amount of O2, just suffocate
				handle_suffocation(breather, o2_pp, safe_oxygen_min, 0)
		else
			// Enough oxygen to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_OXYGEN)
			// Inhale Oxygen, exhale equivalent amount of CO2.
			if(o2_pp)
				breathe_gas_volume(breath, /datum/gas/oxygen, /datum/gas/carbon_dioxide, breath_out)
				// Heal mob if not in crit.
				if(breather.health >= breather.crit_threshold)
					breather.adjustOxyLoss(-5)
=======
	// Treat gas as other types of gas
	for(var/list/conversion_packet in treat_as)
		var/read_from = conversion_packet[BREATH_RELATIONSHIP_INITIAL_GAS]
		if(!partial_pressures[read_from])
			continue
		var/convert_into = conversion_packet[BREATH_RELATIONSHIP_CONVERT]
		partial_pressures[convert_into] += partial_pressures[read_from] * conversion_packet[BREATH_RELATIONSHIP_MULTIPLIER]
		if(partial_pressures[convert_into] <= 0)
			partial_pressures -= convert_into // No negative values jeremy

	// First, we breathe the stuff that always wants to be processed
	// This is typically things like o2, stuff the mob needs to live
	for(var/breath_id in breathe_always)
		var/partial_pressure = partial_pressures[breath_id] || 0
		var/old_partial_pressure = last_partial_pressures[breath_id] || 0
		// Ensures the gas will always be instanciated, so people can interact with it safely
		ASSERT_GAS(breath_id, breath)
		var/inhale = breathe_always[breath_id]
		call(src, inhale)(breather, breath, partial_pressure, old_partial_pressure)
>>>>>>> a773c346beda4 (Fixes ploux, adds conversion support to breath code (#74316))

	//-- NITROGEN --//
	// Maximum Nitrogen effects. "Too much N2!"
	if(safe_nitro_max)
		if(n2_pp && (n2_pp > safe_nitro_max))
			// N2 side-effects.
			var/ratio = (breath_gases[/datum/gas/nitrogen][MOLES]/safe_nitro_max) * 10
			breather.apply_damage_type(clamp(ratio, nitro_breath_dam_min, nitro_breath_dam_max), nitro_damage_type)
			breather.throw_alert(ALERT_TOO_MUCH_NITRO, /atom/movable/screen/alert/too_much_nitro)
		else
			// Reset side-effects.
			breather.clear_alert(ALERT_TOO_MUCH_NITRO)

	// Minimum Nitrogen effects.
	// If the lungs need Nitrogen to breathe properly, N2 is exchanged with CO2.
	if(safe_nitro_min)
		// Suffocation side-effects.
		if(!can_breathe_vacuum && (n2_pp < safe_nitro_min))
			breather.throw_alert(ALERT_NOT_ENOUGH_NITRO, /atom/movable/screen/alert/not_enough_nitro)
			// Inhale insufficient amount of N2, exhale CO2.
			if(n2_pp)
				gas_breathed = handle_suffocation(breather, n2_pp, safe_nitro_min, breath_gases[/datum/gas/nitrogen][MOLES])
				breathe_gas_volume(breath, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, breath_out, volume = gas_breathed)
			else
				// No amount of N2, just suffocate
				handle_suffocation(breather, n2_pp, safe_nitro_min, 0)
		else
			// Enough nitrogen to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_NITRO)
			// Inhale N2, exhale equivalent amount of CO2. Look ma, sideways breathing!
			if(n2_pp)
				breathe_gas_volume(breath, /datum/gas/nitrogen, /datum/gas/carbon_dioxide, breath_out)
				// Heal mob if not in crit.
				if(breather.health >= breather.crit_threshold)
					breather.adjustOxyLoss(-5)

	//-- CARBON DIOXIDE --//
	// Maximum CO2 effects. "Too much CO2!"
	if(safe_co2_max)
		if(co2_pp && (co2_pp > safe_co2_max))
			// CO2 side-effects.
			// Give the mob a chance to notice.
			if(prob(20))
				breather.emote("cough")
			// If it's the first breath with too much CO2 in it, lets start a counter, then have them pass out after 12s or so.
			if(!breather.co2overloadtime)
				breather.co2overloadtime = world.time
			else if((world.time - breather.co2overloadtime) > 12 SECONDS)
				breather.throw_alert(ALERT_TOO_MUCH_CO2, /atom/movable/screen/alert/too_much_co2)
				breather.Unconscious(6 SECONDS)
				// Lets hurt em a little, let them know we mean business.
				breather.apply_damage_type(3, co2_damage_type)
				// They've been in here 30s now, start to kill them for their own good!
				if((world.time - breather.co2overloadtime) > 30 SECONDS)
					breather.apply_damage_type(8, co2_damage_type)
		else
			// Reset side-effects.
			breather.co2overloadtime = 0
			breather.clear_alert(ALERT_TOO_MUCH_CO2)

	// Minimum CO2 effects.
	// If the lungs need CO2 to breathe properly, CO2 is exchanged with O2.
	if(safe_co2_min)
		// Suffocation side-effects.
		if(!can_breathe_vacuum && (co2_pp < safe_co2_min))
			breather.throw_alert(ALERT_NOT_ENOUGH_CO2, /atom/movable/screen/alert/not_enough_co2)
			// Inhale insufficient amount of CO2, exhale O2.
			if(co2_pp)
				gas_breathed = handle_suffocation(breather, co2_pp, safe_co2_min, breath_gases[/datum/gas/carbon_dioxide][MOLES])
				breathe_gas_volume(breath, /datum/gas/carbon_dioxide, /datum/gas/oxygen, breath_out, volume = gas_breathed)
			else
				// No amount of CO2, just suffocate
				handle_suffocation(breather, co2_pp, safe_co2_min, 0)
		else
			// Enough CO2 to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_CO2)
			// Inhale CO2, exhale equivalent amount of O2. Look ma, reverse breathing!
			if(co2_pp)
				breathe_gas_volume(breath, /datum/gas/carbon_dioxide, /datum/gas/oxygen, breath_out)
				// Heal mob if not in crit.
				if(breather.health >= breather.crit_threshold)
					breather.adjustOxyLoss(-5)

	//-- PLASMA --//
	// Maximum Plasma effects. "Too much Plasma!"
	if(safe_plasma_max)
		if(plasma_pp && (plasma_pp > safe_plasma_max))
			// Plasma side-effects.
			var/ratio = (breath_gases[/datum/gas/plasma][MOLES] / safe_plasma_max) * 10
			breather.apply_damage_type(clamp(ratio, plas_breath_dam_min, plas_breath_dam_max), plas_damage_type)
			breather.throw_alert(ALERT_TOO_MUCH_PLASMA, /atom/movable/screen/alert/too_much_plas)
		else
			// Reset side-effects.
			breather.clear_alert(ALERT_TOO_MUCH_PLASMA)

	// Minimum Plasma effects.
	// If the lungs need Plasma to breathe properly, Plasma is exchanged with CO2.
	if(safe_plasma_min)
		// Suffocation side-effects.
		if(!can_breathe_vacuum && (plasma_pp < safe_plasma_min))
			breather.throw_alert(ALERT_NOT_ENOUGH_PLASMA, /atom/movable/screen/alert/not_enough_plas)
			// Breathe insufficient amount of Plasma, exhale CO2.
			if(plasma_pp)
				gas_breathed = handle_suffocation(breather, plasma_pp, safe_plasma_min, breath_gases[/datum/gas/plasma][MOLES])
				breathe_gas_volume(breath, /datum/gas/plasma, /datum/gas/carbon_dioxide, breath_out, volume = gas_breathed)
			else
				// No amount of plasma, just suffocate
				handle_suffocation(breather, plasma_pp, safe_plasma_min, 0)
		else
			// Enough Plasma to breathe.
			breather.failed_last_breath = FALSE
			breather.clear_alert(ALERT_NOT_ENOUGH_PLASMA)
			// Inhale Plasma, exhale equivalent amount of CO2.
			if(plasma_pp)
				breathe_gas_volume(breath, /datum/gas/plasma, /datum/gas/carbon_dioxide, breath_out)
				// Heal mob if not in crit.
				if(breather.health >= breather.crit_threshold)
					breather.adjustOxyLoss(-5)


	//-- TRACES --//
	// If there's some other shit in the air lets deal with it here.

	//-- BZ --//
	if(bz_pp)
		if(bz_pp > BZ_trip_balls_min)
			breather.adjust_hallucinations(20 SECONDS)
			breather.reagents.add_reagent(/datum/reagent/bz_metabolites, 5)
		if(bz_pp > BZ_brain_damage_min && prob(33))
			breather.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150, ORGAN_ORGANIC)

	//-- FREON --//
	if(freon_pp)
		// Inhale Freon. Exhale nothing.
		breathe_gas_volume(breath, /datum/gas/freon)
		if (freon_pp > gas_stimulation_min)
			breather.reagents.add_reagent(/datum/reagent/freon, 1)
		if (prob(freon_pp))
			to_chat(breather, span_alert("Your mouth feels like it's burning!"))
		if (freon_pp > 40)
			breather.emote("gasp")
			breather.adjustFireLoss(15)
			if (prob(freon_pp / 2))
				to_chat(breather, span_alert("Your throat closes up!"))
				breather.set_silence_if_lower(6 SECONDS)
		else
			breather.adjustFireLoss(freon_pp / 4)

	//-- HALON --//
	if(halon_pp)
		// Inhale Halon. Exhale nothing.
		breathe_gas_volume(breath, /datum/gas/halon)
		// Metabolize to reagent.
		if(halon_pp > gas_stimulation_min)
			breather.adjustOxyLoss(5)
			breather.reagents.add_reagent(/datum/reagent/halon, max(0, 1 - breather.reagents.get_reagent_amount(/datum/reagent/halon)))

	//-- HEALIUM --//
	// Sleeping gas with healing properties.
	if(!healium_pp)
		// Reset side-effects.
		healium_euphoria = EUPHORIA_INACTIVE
	else
		// Inhale Healium. Exhale nothing.
		breathe_gas_volume(breath, /datum/gas/healium)
		// Euphoria side-effect.
		if(healium_pp > gas_stimulation_min)
			if(prob(15))
				to_chat(breather, span_alert("Your head starts spinning and your lungs burn!"))
				healium_euphoria = EUPHORIA_ACTIVE
				breather.emote("gasp")
		else
			healium_euphoria = EUPHORIA_INACTIVE
		// Stun/Sleep side-effects.
		if(healium_pp > healium_para_min)
			// Random chance to stun mob. Timing not in seconds to have a much higher variation
			breather.Unconscious(rand(3 SECONDS, 5 SECONDS))
		// Metabolize to reagent when concentration is high enough.
		if(healium_pp > healium_sleep_min)
			breather.reagents.add_reagent(/datum/reagent/healium, max(0, 1 - breather.reagents.get_reagent_amount(/datum/reagent/healium)))

	//-- HELIUM --//
	// Activates helium speech when partial pressure gets high enough
	if(!helium_pp)
		helium_speech = FALSE
		UnregisterSignal(breather, COMSIG_MOB_SAY)
	else
		// Inhale Helium. Exhale nothing.
		breathe_gas_volume(breath, /datum/gas/helium)
		// Helium side-effects.
		if(helium_speech && (helium_pp <= helium_speech_min))
			helium_speech = FALSE
			UnregisterSignal(breather, COMSIG_MOB_SAY)
		else if(!helium_speech && (helium_pp > helium_speech_min))
			helium_speech = TRUE
			RegisterSignal(breather, COMSIG_MOB_SAY, PROC_REF(handle_helium_speech))

	//-- HYPER-NOBILUM --//
	if(hypernob_pp)
		// Inhale Hyber-Nobilum. Exhale nothing.
		breathe_gas_volume(breath, /datum/gas/hypernoblium)
		// Metabolize to reagent.
		if (hypernob_pp > gas_stimulation_min)
			var/existing = breather.reagents.get_reagent_amount(/datum/reagent/hypernoblium)
			breather.reagents.add_reagent(/datum/reagent/hypernoblium,max(0, 1 - existing))

	//-- MIASMA --//
	if(!miasma_pp || !suffers_miasma)
		// Clear out moods when immune to miasma, or if there's no miasma at all.
		breather.clear_mood_event("smell")
	else
		// Inhale Miasma. Exhale nothing.
		breathe_gas_volume(breath, /datum/gas/miasma)
		// Miasma sickness
		if(prob(0.5 * miasma_pp))
			var/datum/disease/advance/miasma_disease = new /datum/disease/advance/random(max_symptoms = min(round(max(miasma_pp / 2, 1), 1), 6), max_level = min(round(max(miasma_pp, 1), 1), 8))
			// tl;dr the first argument chooses the smaller of miasma_pp/2 or 6(typical max virus symptoms), the second chooses the smaller of miasma_pp or 8(max virus symptom level)
			// Each argument has a minimum of 1 and rounds to the nearest value. Feel free to change the pp scaling I couldn't decide on good numbers for it.
			miasma_disease.name = "Unknown"
			miasma_disease.try_infect(breather)
		// Miasma side effects
		switch(miasma_pp)
			if(0.25 to 5)
				// At lower pp, give out a little warning
				breather.clear_mood_event("smell")
				if(prob(5))
					to_chat(breather, span_notice("There is an unpleasant smell in the air."))
			if(5 to 15)
				//At somewhat higher pp, warning becomes more obvious
				if(prob(15))
					to_chat(breather, span_warning("You smell something horribly decayed inside this room."))
					breather.add_mood_event("smell", /datum/mood_event/disgust/bad_smell)
			if(15 to 30)
				//Small chance to vomit. By now, people have internals on anyway
				if(prob(5))
					to_chat(breather, span_warning("The stench of rotting carcasses is unbearable!"))
					breather.add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
					breather.vomit()
			if(30 to INFINITY)
				//Higher chance to vomit. Let the horror start
				if(prob(15))
					to_chat(breather, span_warning("The stench of rotting carcasses is unbearable!"))
					breather.add_mood_event("smell", /datum/mood_event/disgust/nauseating_stench)
					breather.vomit()
			else
				breather.clear_mood_event("smell")
		// In a full miasma atmosphere with 101.34 pKa, about 10 disgust per breath, is pretty low compared to threshholds
		// Then again, this is a purely hypothetical scenario and hardly reachable
		breather.adjust_disgust(0.1 * miasma_pp)

	//-- N2O --//
	// N2O side-effects. "Too much N2O!"
	// Small amount of N2O, small side-effects. Causes random euphoria and giggling.
	if (n2o_pp > n2o_para_min)
		// More N2O, more severe side-effects. Causes stun/sleep.
		n2o_euphoria = EUPHORIA_ACTIVE
		breather.throw_alert(ALERT_TOO_MUCH_N2O, /atom/movable/screen/alert/too_much_n2o)
		// 60 gives them one second to wake up and run away a bit!
		breather.Unconscious(6 SECONDS)
		// Enough to make the mob sleep.
		// NON-MODULAR CHANGES
		var/amount_of_sleep = min(breather.AmountSleeping() + 10 SECONDS, 20 SECONDS)
		if(n2o_pp > n2o_sleep_min && breather.Sleeping(amount_of_sleep))
			// If we got put to sleep we count as "on anesthetic"
			breather.apply_status_effect(/datum/status_effect/grouped/anesthetic, /datum/gas/nitrous_oxide)
		// NON-MODULAR CHANGES END
		if(n2o_pp > n2o_sleep_min)
			breather.Sleeping(min(breather.AmountSleeping() + 100, 200))
	else if(n2o_pp > 0.01)
		// No alert for small amounts, but the mob randomly feels euphoric.
		breather.clear_alert(ALERT_TOO_MUCH_N2O)
		if(prob(20))
			n2o_euphoria = EUPHORIA_ACTIVE
			breather.emote(pick("giggle", "laugh"))
		else
			n2o_euphoria = EUPHORIA_INACTIVE
	else
		// Reset side-effects, for zero or extremely small amounts of N2O.
		n2o_euphoria = EUPHORIA_INACTIVE
		breather.clear_alert(ALERT_TOO_MUCH_N2O)
		// NON-MODULAR CHANGES: Pain anesthetic
		breather.remove_status_effect(/datum/status_effect/grouped/anesthetic, /datum/gas/nitrous_oxide)

	//-- NITRIUM --//
	if (nitrium_pp)
		// Inhale Nitrium. Exhale nothing.
		breathe_gas_volume(breath, /datum/gas/nitrium)
		// Random chance to inflict side effects increases with pressure.
		if((prob(nitrium_pp) && (nitrium_pp > 15)))
			// Nitrium side-effect.
			breather.adjustOrganLoss(ORGAN_SLOT_LUNGS, nitrium_pp * 0.1)
			to_chat(breather, "<span class='notice'>You feel a burning sensation in your chest</span>")
		// Metabolize to reagents.
		if (nitrium_pp > 5)
			var/existing = breather.reagents.get_reagent_amount(/datum/reagent/nitrium_low_metabolization)
			breather.reagents.add_reagent(/datum/reagent/nitrium_low_metabolization, max(0, 2 - existing))
		if (nitrium_pp > 10)
			var/existing = breather.reagents.get_reagent_amount(/datum/reagent/nitrium_high_metabolization)
			breather.reagents.add_reagent(/datum/reagent/nitrium_high_metabolization, max(0, 1 - existing))

	//-- PROTO-NITRATE --//
	// Inert

	//-- TRITIUM --//
	if (trit_pp)
		// Inhale Tritium. Exhale nothing.
		gas_breathed = breathe_gas_volume(breath, /datum/gas/tritium)
		// Tritium side-effects.
		var/ratio = gas_breathed * 15
		breather.adjustToxLoss(clamp(ratio, MIN_TOXIC_GAS_DAMAGE, MAX_TOXIC_GAS_DAMAGE))
		// If you're breathing in half an atmosphere of radioactive gas, you fucked up.
		if((trit_pp > tritium_irradiation_moles_min) && SSradiation.can_irradiate_basic(breather))
			var/lerp_scale = min(tritium_irradiation_moles_max, trit_pp - tritium_irradiation_moles_min) / (tritium_irradiation_moles_max - tritium_irradiation_moles_min)
			var/chance = LERP(tritium_irradiation_probability_min, tritium_irradiation_probability_max, lerp_scale)
			if (prob(chance))
				breather.AddComponent(/datum/component/irradiated)

	//-- ZAUKER --//
	if(zauker_pp)
		// Inhale Zauker. Exhale nothing.
		breathe_gas_volume(breath, /datum/gas/zauker)
		// Metabolize to reagent.
		if(zauker_pp > gas_stimulation_min)
			var/existing = breather.reagents.get_reagent_amount(/datum/reagent/zauker)
			breather.reagents.add_reagent(/datum/reagent/zauker, max(0, 1 - existing))

	// Handle chemical euphoria mood event, caused by gases such as N2O or healium.
	if (n2o_euphoria == EUPHORIA_ACTIVE || healium_euphoria == EUPHORIA_ACTIVE)
		breather.add_mood_event("chemical_euphoria", /datum/mood_event/chemical_euphoria)
	else if (n2o_euphoria == EUPHORIA_INACTIVE && healium_euphoria == EUPHORIA_INACTIVE)
		breather.clear_mood_event("chemical_euphoria")
	// Activate mood on first flag, remove on second, do nothing on third.

	if(has_moles)
		handle_breath_temperature(breath, breather)
		// Transfer exchanged gases into breath for exhalation.
		for(var/gas_type in breath_gases_out)
			breath.assert_gas(gas_type)
			breath_gases[gas_type][MOLES] += breath_gases_out[gas_type][MOLES]
		// Resets immutable gas_mixture to empty.
		breath_out.garbage_collect()

	breath.garbage_collect()

	// Returned status code 0 indicates breath failed.
	if(!breather.failed_last_breath)
		return TRUE

///override this for breath handling unique to lung subtypes, breath_gas is the list of gas in the breath while gas breathed is just what is being added or removed from that list, just as they are when this is called in check_breath()
/obj/item/organ/internal/lungs/proc/handle_gas_override(mob/living/carbon/human/breather, list/breath_gas, gas_breathed)
	return

/// Remove gas from breath. If output_gas and breath_out arguments are given, transfers the removed gas to breath_out.
/// Removes 100% of the given gas type unless given a volume argument.
/// Returns the amount of gas theoretically removed.
/obj/item/organ/internal/lungs/proc/breathe_gas_volume(datum/gas_mixture/breath, datum/gas/input_gas = null, datum/gas/output_gas = null, datum/gas_mixture/breath_out = null, volume = INFINITY)
	var/gases_in = breath.gases
	volume = min(volume, gases_in[input_gas][MOLES])
	gases_in[input_gas][MOLES] -= volume
	if(output_gas && breath_out)
		breath_out.assert_gas(output_gas)
		breath_out.gases[output_gas][MOLES] += volume
	return volume

/// Applies suffocation side-effects to a given Human, scaling based on ratio of required pressure VS "true" pressure.
/// If pressure is greater than 0, the return value will represent the amount of gas successfully breathed.
/obj/item/organ/internal/lungs/proc/handle_suffocation(mob/living/carbon/human/suffocator = null, breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	// Can't suffocate without a Human, or without minimum breath pressure.
	if(!suffocator || !safe_breath_min)
		return
	// Mob is suffocating.
	suffocator.failed_last_breath = TRUE
	// Give them a chance to notice something is wrong.
	if(prob(20))
		suffocator.emote("gasp")
	// If mob is at critical health, check if they can be damaged further.
	if(suffocator.health < suffocator.crit_threshold)
		// Mob is immune to damage at critical health.
		if(HAS_TRAIT(suffocator, TRAIT_NOCRITDAMAGE))
			return
		// Reagents like Epinephrine stop suffocation at critical health.
		if(suffocator.reagents.has_reagent(crit_stabilizing_reagent, needs_metabolizing = TRUE))
			return
	// Low pressure.
	if(breath_pp)
		var/ratio = safe_breath_min / breath_pp
		suffocator.adjustOxyLoss(min(5 * ratio, HUMAN_MAX_OXYLOSS))
		return true_pp * ratio / 6
	// Zero pressure.
	if(suffocator.health >= suffocator.crit_threshold)
		suffocator.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
	else
		suffocator.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)


/obj/item/organ/internal/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/breather) // called by human/life, handles temperatures
	var/breath_temperature = breath.temperature

	if(!HAS_TRAIT(breather, TRAIT_RESISTCOLD)) // COLD DAMAGE
		var/cold_modifier = breather.dna.species.coldmod
		if(breath_temperature < cold_level_3_threshold)
			breather.apply_damage_type(cold_level_3_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_3_threshold && breath_temperature < cold_level_2_threshold)
			breather.apply_damage_type(cold_level_2_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_2_threshold && breath_temperature < cold_level_1_threshold)
			breather.apply_damage_type(cold_level_1_damage*cold_modifier, cold_damage_type)
		if(breath_temperature < cold_level_1_threshold)
			if(prob(20))
				to_chat(breather, span_warning("You feel [cold_message] in your [name]!"))

	if(!HAS_TRAIT(breather, TRAIT_RESISTHEAT)) // HEAT DAMAGE
		var/heat_modifier = breather.dna.species.heatmod
		if(breath_temperature > heat_level_1_threshold && breath_temperature < heat_level_2_threshold)
			breather.apply_damage_type(heat_level_1_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_2_threshold && breath_temperature < heat_level_3_threshold)
			breather.apply_damage_type(heat_level_2_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_3_threshold)
			breather.apply_damage_type(heat_level_3_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_1_threshold)
			if(prob(20))
				to_chat(breather, span_warning("You feel [hot_message] in your [name]!"))

	// The air you breathe out should match your body temperature
	breath.temperature = breather.bodytemperature

/obj/item/organ/internal/lungs/proc/handle_helium_speech(owner, list/speech_args)
	SIGNAL_HANDLER
	speech_args[SPEECH_SPANS] |= SPAN_HELIUM

/obj/item/organ/internal/lungs/on_life(delta_time, times_fired)
	. = ..()
	if(failed && !(organ_flags & ORGAN_FAILING))
		failed = FALSE
		return
	if(damage >= low_threshold)
		var/do_i_cough = DT_PROB((damage < high_threshold) ? 2.5 : 5, delta_time) // between : past high
		if(do_i_cough)
			owner.emote("cough")
	if(organ_flags & ORGAN_FAILING && owner.stat == CONSCIOUS)
		owner.visible_message(span_danger("[owner] grabs [owner.p_their()] throat, struggling for breath!"), span_userdanger("You suddenly feel like you can't breathe!"))
		failed = TRUE

/obj/item/organ/internal/lungs/get_availability(datum/species/owner_species, mob/living/owner_mob)
	return owner_species.mutantlungs

/obj/item/organ/internal/lungs/plasmaman
	name = "plasma filter"
	desc = "A spongy rib-shaped mass for filtering plasma from the air."
	icon_state = "lungs-plasma"
	organ_traits = list(TRAIT_NOHUNGER) // A fresh breakfast of plasma is a great start to any morning.

	safe_oxygen_min = 0 //We don't breathe this
	safe_plasma_min = 4 //We breathe THIS!
	safe_plasma_max = 0

/obj/item/organ/internal/lungs/slime
	name = "vacuole"
	desc = "A large organelle designed to store oxygen and other important gasses."

	safe_plasma_max = 0 //We breathe this to gain POWER.

/obj/item/organ/internal/lungs/slime/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/breather_slime)
	. = ..()
	if (breath?.gases[/datum/gas/plasma])
		var/plasma_pp = breath.get_breath_partial_pressure(breath.gases[/datum/gas/plasma][MOLES])
		breather_slime.blood_volume += (0.2 * plasma_pp) // 10/s when breathing literally nothing but plasma, which will suffocate you.

/obj/item/organ/internal/lungs/cybernetic
	name = "basic cybernetic lungs"
	desc = "A basic cybernetic version of the lungs found in traditional humanoid entities."
	icon_state = "lungs-c"
	organ_flags = ORGAN_SYNTHETIC
	maxHealth = STANDARD_ORGAN_THRESHOLD * 0.5

	var/emp_vulnerability = 80 //Chance of permanent effects if emp-ed.

/obj/item/organ/internal/lungs/cybernetic/tier2
	name = "cybernetic lungs"
	desc = "A cybernetic version of the lungs found in traditional humanoid entities. Allows for greater intakes of oxygen than organic lungs, requiring slightly less pressure."
	icon_state = "lungs-c-u"
	maxHealth = 1.5 * STANDARD_ORGAN_THRESHOLD
	safe_oxygen_min = 13
	emp_vulnerability = 40

/obj/item/organ/internal/lungs/cybernetic/tier3
	name = "upgraded cybernetic lungs"
	desc = "A more advanced version of the stock cybernetic lungs. Features the ability to filter out lower levels of plasma and carbon dioxide."
	icon_state = "lungs-c-u2"
	safe_plasma_max = 20
	safe_co2_max = 20
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD
	safe_oxygen_min = 13
	emp_vulnerability = 20

	cold_level_1_threshold = 200
	cold_level_2_threshold = 140
	cold_level_3_threshold = 100

/obj/item/organ/internal/lungs/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(!COOLDOWN_FINISHED(src, severe_cooldown)) //So we cant just spam emp to kill people.
		owner.losebreath += 20
		COOLDOWN_START(src, severe_cooldown, 30 SECONDS)
	if(prob(emp_vulnerability/severity)) //Chance of permanent effects
		organ_flags |= ORGAN_SYNTHETIC_EMP //Starts organ faliure - gonna need replacing soon.


/obj/item/organ/internal/lungs/lavaland
	name = "blackened frilled lungs" // blackened from necropolis exposure
	desc = "Exposure to the necropolis has mutated these lungs to breathe the air of Indecipheres, the lava-covered moon."
	icon_state = "lungs-ashwalker"

// Normal oxygen is 21 kPa partial pressure, but SS13 humans can tolerate down
// to 16 kPa. So it follows that ashwalkers, as humanoids, follow the same rules.
#define GAS_TOLERANCE 5

/obj/item/organ/internal/lungs/lavaland/Initialize(mapload)
	. = ..()

	var/datum/gas_mixture/immutable/planetary/mix = SSair.planetary[LAVALAND_DEFAULT_ATMOS]

	if(!mix?.total_moles()) // this typically means we didn't load lavaland, like if we're using #define LOWMEMORYMODE
		return

	// Take a "breath" of the air
	var/datum/gas_mixture/breath = mix.remove(mix.total_moles() * BREATH_PERCENTAGE)

	var/list/breath_gases = breath.gases

	breath.assert_gases(
		/datum/gas/oxygen,
		/datum/gas/plasma,
		/datum/gas/carbon_dioxide,
		/datum/gas/nitrogen,
		/datum/gas/bz,
		/datum/gas/miasma,
	)

	var/oxygen_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/oxygen][MOLES])
	var/nitrogen_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/nitrogen][MOLES])
	var/plasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/plasma][MOLES])
	var/carbon_dioxide_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/carbon_dioxide][MOLES])
	var/bz_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/bz][MOLES])
	var/miasma_pp = breath.get_breath_partial_pressure(breath_gases[/datum/gas/miasma][MOLES])

	safe_oxygen_min = max(0, oxygen_pp - GAS_TOLERANCE)
	safe_nitro_min = max(0, nitrogen_pp - GAS_TOLERANCE)
	safe_plasma_min = max(0, plasma_pp - GAS_TOLERANCE)

	// Increase plasma tolerance based on amount in base air
	safe_plasma_max += plasma_pp

	// CO2 is always a waste gas, so none is required, but ashwalkers
	// tolerate the base amount plus tolerance*2 (humans tolerate only 10 pp)

	safe_co2_max = carbon_dioxide_pp + GAS_TOLERANCE * 2

	// The lung tolerance against BZ is also increased the amount of BZ in the base air
	BZ_trip_balls_min += bz_pp
	BZ_brain_damage_min += bz_pp

	// Lungs adapted to a high miasma atmosphere do not process it, and breathe it back out
	if(miasma_pp)
		suffers_miasma = FALSE

#undef GAS_TOLERANCE

/obj/item/organ/internal/lungs/ethereal
	name = "aeration reticulum"
	desc = "These exotic lungs seem crunchier than most."
	icon_state = "lungs_ethereal"
	heat_level_1_threshold = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD // 150C or 433k, in line with ethereal max safe body temperature
	heat_level_2_threshold = 473
	heat_level_3_threshold = 1073


<<<<<<< HEAD
/obj/item/organ/internal/lungs/ethereal/handle_gas_override(mob/living/carbon/human/breather, list/breath_gases, gas_breathed)
	// H2O electrolysis
	gas_breathed = breath_gases[/datum/gas/water_vapor][MOLES]
	breath_gases[/datum/gas/oxygen][MOLES] += gas_breathed
	breath_gases[/datum/gas/hydrogen][MOLES] += gas_breathed*2
	breath_gases[/datum/gas/water_vapor][MOLES] -= gas_breathed
=======
/// H2O electrolysis
/obj/item/organ/internal/lungs/ethereal/proc/consume_water(mob/living/carbon/breather, datum/gas_mixture/breath, h2o_pp, old_h2o_pp)
	var/gas_breathed = breath.gases[/datum/gas/water_vapor][MOLES]
	breath.gases[/datum/gas/water_vapor][MOLES] -= gas_breathed
	breath_out.assert_gases(/datum/gas/oxygen, /datum/gas/hydrogen)
	breath_out.gases[/datum/gas/oxygen][MOLES] += gas_breathed
	breath_out.gases[/datum/gas/hydrogen][MOLES] += gas_breathed * 2


#undef BREATH_RELATIONSHIP_INITIAL_GAS
#undef BREATH_RELATIONSHIP_CONVERT
#undef BREATH_RELATIONSHIP_MULTIPLIER
>>>>>>> a773c346beda4 (Fixes ploux, adds conversion support to breath code (#74316))
