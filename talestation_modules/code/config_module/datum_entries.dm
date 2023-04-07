// Modular config entries should go here

/// Datum for if crew transfer votes are allowed, period
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

/// Config entry for transfe vote shuttle call reason
/datum/config_entry/string/transfer_call_reason
	default = "Crew transfer vote successful, dispatching shuttle for shift change."

/// Config entry for allowing pixelshift
/datum/config_entry/flag/pixelshift_toggle_allow
	default = FALSE
