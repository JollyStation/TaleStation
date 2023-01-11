/**
 * ## Crew Transfer Vote SS
 *
 * Tracks information about Crew transfer votes and calls auto transfer votes.
 *
 * If enabled, calls a vote [minimum_transfer_time] into the round, and every [minimum_time_between_votes] after that.
 */
SUBSYSTEM_DEF(crewtransfer)
	name = "Crew Transfer Vote"
	wait = 60 SECONDS // Upped in init
	runlevels = RUNLEVEL_GAME

	/// Number of votes attempted total, including auto and manual votes
	var/transfer_votes_attempted = 0
	/// Minimum shift length before automatic votes begin - from config.
	var/minimum_transfer_time = 0
	/// Minimum length of time between automatic votes - from config.
	var/minimum_time_between_votes = 0
	/// We stop calling votes if a vote passed
	var/transfer_vote_successful = FALSE
	/// What do we say when the shuttle's called
	var/shuttle_call_reason = "Crew transfer vote successful."

/datum/controller/subsystem/crewtransfer/Initialize(timeofday)
	if(!CONFIG_GET(flag/transfer_auto_vote_enabled))
		can_fire = FALSE

	// Disable if we're in testing mode, it'd get annoying
	#ifdef TESTING
	can_fire = FALSE
	#endif

	// Disable if we're unit testing, it doesn't make sense
	#ifdef UNIT_TESTS
	can_fire = FALSE
	#endif

	if(!can_fire)
		return SS_INIT_NO_NEED

	minimum_transfer_time = CONFIG_GET(number/transfer_time_min_allowed)
	minimum_time_between_votes = CONFIG_GET(number/transfer_time_between_auto_votes)
	shuttle_call_reason = CONFIG_GET(string/transfer_call_reason)
	wait = minimum_transfer_time //first vote will fire at [minimum_transfer_time]
	return SS_INIT_SUCCESS

/datum/controller/subsystem/crewtransfer/fire()
	//we can't vote if we don't have a functioning democracy
	if(!SSvote || !SSvote.initialized)
		disable_vote()
		CRASH("The crew transfer vote system tried to fire, but no vote subsystem / no initialized vote subsystem was found!")

	//if it fires before it's supposed to be allowed, cut it out
	if(world.time - SSticker.round_start_time < minimum_transfer_time)
		return

	//if the shuttle is called and uncreallable, docked or beyond, or a transfer vote succeeded, stop firing
	if(EMERGENCY_PAST_POINT_OF_NO_RETURN || transfer_vote_successful)
		disable_vote()
		return

	//time to actually call the transfer vote.
	//if the transfer vote is unable to be called, try again in 2 minutes.
	//if the transfer vote begins successfully, then we'll come back in [minimum_time_between_votes]
	wait = autocall_crew_transfer_vote() ? minimum_time_between_votes : 2 MINUTES

/// prevents the crew transfer SS from firing.
/datum/controller/subsystem/crewtransfer/proc/disable_vote()
	can_fire = FALSE
	log_shuttle("[name] subsystem has been disabled and automatic votes will no longer be called.")
	message_admins("[name] subsystem has been disabled and automatic votes will no longer be called.")
	return TRUE

/// Call an crew transfer vote from the server if a vote isn't running.
/// returns TRUE if it successfully called a vote, FALSE if it failed.
/datum/controller/subsystem/crewtransfer/proc/autocall_crew_transfer_vote()
	//we won't call a vote if we shouldn't be able to leave
	if(SSshuttle.emergency_no_escape)
		log_shuttle("Automatic crew transfer vote delayed due to a hostile situation.")
		message_admins("Automatic crew transfer vote delayed due to a hostile situation.")
		return FALSE

	//we won't call a vote if a vote is running
	if(SSvote.current_vote)
		log_shuttle("Automatic crew transfer vote delayed due to ongoing vote.")
		message_admins("Automatic crew transfer vote delayed due to ongoing vote.")
		return FALSE

	log_shuttle("Automatic crew transfer vote initiated.")
	message_admins("Automatic crew transfer vote initiated.")
	return SSvote.initiate_vote(/datum/vote/autotransfer, "the server", forced = TRUE)

/// initiates the shuttle call and logs it.
/datum/controller/subsystem/crewtransfer/proc/initiate_crew_transfer()
	if(EMERGENCY_IDLE_OR_RECALLED)
		/// The multiplier on the shuttle's timer
		var/shuttle_time_mult = 1
		/// Security level (for timer multiplier)
		switch(SSsecurity_level.get_current_level_as_number())
			if(SEC_LEVEL_GREEN)
				shuttle_time_mult = 2 // = ~20 minutes
			if(SEC_LEVEL_BLUE, SEC_LEVEL_RED)
				shuttle_time_mult = 1.5 // = ~15 minutes, =~7.5 minutes

		SSshuttle.emergency.request(reason = "\nReason:\n\n[shuttle_call_reason]", set_coefficient = shuttle_time_mult)

		log_shuttle("A crew transfer vote has passed. The shuttle has been called, and recalling the shuttle ingame is disabled.")
		message_admins("A crew transfer vote has passed. The shuttle has been called, and recalling the shuttle ingame is disabled.")
		deadchat_broadcast("A crew transfer vote has passed. The shuttle is being dispatched.",  message_type = DEADCHAT_ANNOUNCEMENT)
		SSblackbox.record_feedback("text", "shuttle_reason", 1, "Crew Transfer Vote")
	else
		log_shuttle("A crew transfer vote has passed, but the shuttle was already called. Recalling the shuttle ingame is disabled.")
		message_admins("A crew transfer vote has passed, but the shuttle was already called. Recalling the shuttle ingame is disabled.")
		to_chat(world, span_boldannounce("Crew transfer vote failed on account of shuttle being called."))

	SSshuttle.admin_emergency_no_recall = TRUE // Don't let one guy overrule democracy by recalling afterwards
	transfer_vote_successful = TRUE
	return TRUE

/datum/config_entry/flag/allow_vote_transfer
	default = FALSE // Disabled

/// Automatic crew transfer votes that start at [transfer_time_min_allowed] and happen every [transfer_time_between_auto_votes]
/datum/config_entry/flag/transfer_auto_vote_enabled
	default = TRUE // Enabled

/// Minimum shift length before transfer votes can begin
/datum/config_entry/number/transfer_time_min_allowed
	default = 1.5 HOURS
	integer = FALSE
	min_val = 5 MINUTES

/// Time between auto transfer votes
/datum/config_entry/number/transfer_time_between_auto_votes
	default = 30 MINUTES
	integer = FALSE
	min_val = 2 MINUTES

/datum/config_entry/string/transfer_call_reason
	default = "Crew transfer vote successful, dispatching shuttle for shift change."
