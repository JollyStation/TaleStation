/// -- High draconic language. It's like Draconic, but more posh. --
// Credit to EOBgames for the initial syllables list / concept, changed and adapted for use.

/datum/language/impdraconic
	name = "High Draconic"
	desc = "A distinct dialect of Draconic common to lizards born and raised in the Core Systems of the Lizard Empire."
	//speech_verb = "hisses"
	//ask_verb = "hisses"
	//exclaim_verb = "roars"
	//sing_verb = "sings"
	key = "l"
	flags = TONGUELESS_SPEECH
	space_chance = 25
	syllables = list(
		"ta", "te", "ti", "to", "tu", "ez", "la", "ro", "fe", "ss", "es", "me", "da",
		"ra", "re", "ri", "ll", "as", "fa", "mer", "za", "ze", "ssa", "ko", "ka", "de",
		"ba", "be", "ma", "bi", "sk", "hi", "hs", "ke", "ssi", "le", "mo", "is", "ek", "a",
		"e", "i", "o", "u", "u", "ru", "sa", "sr", "rs", "us"
	)
	icon = 'talestation_modules/icons/species/language.dmi'
	icon_state = "lizardred"
	default_priority = 85

// Edit to the base lizard language holder - lizards can understand high draconic.
/datum/language_holder/lizard/New(atom/_owner)
	understood_languages += list(
		/datum/language/impdraconic = list(LANGUAGE_ATOM)
		)

// Edit to the silverscale language holder - silverscales can speak high draconic.
/datum/language_holder/lizard/silver/New(atom/_owner)
	understood_languages += list(
		/datum/language/impdraconic = list(LANGUAGE_ATOM)
		)
	spoken_languages += list(
		/datum/language/impdraconic = list(LANGUAGE_ATOM)
		)
