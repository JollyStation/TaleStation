/datum/ai_controller/basic_controller/bot/clean
	blackboard = list(
		BB_TARGETTING_DATUM = new /datum/targetting_datum/cleanbot(),
		BB_CLEAN_BOT_TARGET = null,
		BB_IGNORE_LIST = list(),
	)

	planning_subtrees = list(
		/datum/ai_planning_subtree/bot_clear_ignore_list,
		/datum/ai_planning_subtree/cleanbot_get_saluted,
		/datum/ai_planning_subtree/cleanbot_throw_foam,
		/datum/ai_planning_subtree/clean_target_emagged,
		/datum/ai_planning_subtree/bot_summoning,
		/datum/ai_planning_subtree/clean_target,
		/datum/ai_planning_subtree/watch_for_filth,
		/datum/ai_planning_subtree/bot_patrolling,
	)

	COOLDOWN_DECLARE(next_salute_check)

///Handles the behavior of cleaning if we are emagged
/datum/ai_planning_subtree/clean_target_emagged/SelectBehaviors(datum/ai_controller/controller, delta_time)
	var/mob/living/basic/bot/bot = controller.pawn

	if(controller.blackboard[BB_CLEAN_BOT_TARGET] && bot.bot_cover_flags & BOT_COVER_EMAGGED) //We are going to evilmax!
		controller.set_movement_target(controller.blackboard[BB_CLEAN_BOT_TARGET], /datum/ai_movement/basic_avoidance)
		controller.queue_behavior(/datum/ai_behavior/evil_clean, BB_CLEAN_BOT_TARGET, BB_TARGETTING_DATUM)

///Tries to move to and clean the specified target.
/datum/ai_planning_subtree/clean_target/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	if(controller.blackboard[BB_CLEAN_BOT_TARGET])
		controller.set_movement_target(controller.blackboard[BB_CLEAN_BOT_TARGET], /datum/ai_movement/basic_avoidance)
		controller.queue_behavior(/datum/ai_behavior/clean, BB_CLEAN_BOT_TARGET, BB_TARGETTING_DATUM)
		return SUBTREE_RETURN_FINISH_PLANNING

///Updates the blackboard with the current targets that can be targetted by the AI based on the specified janitor mode flags
/datum/ai_controller/basic_controller/bot/clean/proc/set_valid_targets(valid_targets)
	blackboard[BB_CLEAN_BOT_VALID_TARGETS] = valid_targets

///Look for filthy things while idling too!
/datum/ai_planning_subtree/watch_for_filth/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()
	controller.queue_behavior(/datum/ai_behavior/scan, BB_CLEAN_BOT_TARGET, BB_TARGETTING_DATUM)


///Commisioned clean bots can demand some respect!
/datum/ai_planning_subtree/cleanbot_get_saluted/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()

	var/datum/ai_controller/basic_controller/bot/clean/cleanbot_controller = controller

	if(cleanbot_controller.blackboard[BB_BOT_IS_COMMISSIONED] && COOLDOWN_FINISHED(cleanbot_controller, next_salute_check))
		cleanbot_controller.queue_behavior(/datum/ai_behavior/scan, BB_CLEAN_BOT_TARGET, BB_TARGETTING_DATUM)
		COOLDOWN_START(cleanbot_controller, next_salute_check, BOT_COMMISSIONED_SALUTE_DELAY)

///Emagged cleanbots spray foam all over!
/datum/ai_planning_subtree/cleanbot_throw_foam/SelectBehaviors(datum/ai_controller/controller, delta_time)
	. = ..()

	var/mob/living/basic/bot/bot = controller.pawn

	if(bot.bot_cover_flags & BOT_COVER_EMAGGED)
		controller.queue_behavior(/datum/ai_behavior/spray_foam)
