/obj/machinery/computer/security/telescreen
	name = "\improper Telescreen"
	desc = "Used for watching an empty arena."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "telescreen"
	icon_keyboard = null
	icon_screen = null
	layer = SIGN_LAYER
	network = list(CAMERANET_NETWORK_THUNDERDOME)
	density = FALSE
	circuit = null
	light_power = 0
	/// The kind of wallframe that this telescreen drops
	var/frame_type = /obj/item/wallframe/telescreen

/obj/item/wallframe/telescreen
	name = "telescreen frame"
	desc = "A wall-mountable telescreen frame. Apply to wall to use."
	icon = 'icons/obj/wallmounts.dmi'
	icon_state = "telescreen"
	result_path = /obj/machinery/computer/security/telescreen
	pixel_shift = 32

/obj/machinery/computer/security/telescreen/on_deconstruction(disassembled)
	new frame_type(loc)

/obj/machinery/computer/security/telescreen/update_icon_state()
	icon_state = initial(icon_state)
	if(machine_stat & BROKEN)
		icon_state += "b"
	return ..()

/obj/machinery/computer/security/telescreen/entertainment
	name = "entertainment monitor"
	desc = "Damn, they better have the /tg/ channel on these things."
	icon = 'icons/obj/machines/status_display.dmi'
	icon_state = "entertainment_blank"
	network = list()
	density = FALSE
	circuit = null
	interaction_flags_atom = INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_NO_FINGERPRINT_INTERACT | INTERACT_ATOM_NO_FINGERPRINT_ATTACK_HAND | INTERACT_MACHINE_REQUIRES_SIGHT
	frame_type = /obj/item/wallframe/telescreen/entertainment
	var/icon_state_off = "entertainment_blank"
	var/icon_state_on = "entertainment"

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/entertainment, 32)

/obj/item/wallframe/telescreen/entertainment
	name = "entertainment telescreen frame"
	icon = 'icons/obj/machines/status_display.dmi'
	icon_state = "entertainment_blank"
	result_path = /obj/machinery/computer/security/telescreen/entertainment

/obj/machinery/computer/security/telescreen/entertainment/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_CLICK, PROC_REF(BigClick))
	find_and_hang_on_wall()

// Bypass clickchain to allow humans to use the telescreen from a distance
/obj/machinery/computer/security/telescreen/entertainment/proc/BigClick()
	SIGNAL_HANDLER

	if(!network.len)
		balloon_alert(usr, "nothing on TV!")
		return

	INVOKE_ASYNC(src, TYPE_PROC_REF(/atom, interact), usr)

///Sets the monitor's icon to the selected state, and says an announcement
/obj/machinery/computer/security/telescreen/entertainment/proc/notify(on, announcement)
	if(on && icon_state == icon_state_off)
		icon_state = icon_state_on
	else
		icon_state = icon_state_off
	if(announcement)
		say(announcement)

/// Adds a camera network ID to the entertainment monitor, and turns off the monitor if network list is empty
/obj/machinery/computer/security/telescreen/entertainment/proc/update_shows(is_show_active, tv_show_id, announcement)
	if(!network)
		return

	if(is_show_active)
		network |= tv_show_id
	else
		network -= tv_show_id

	notify(network.len, announcement)

/obj/machinery/computer/security/telescreen/rd
	name = "\improper Research Director's telescreen"
	desc = "Used for watching the AI and the RD's goons from the safety of his office."
	network = list(
		CAMERANET_NETWORK_RD,
		CAMERANET_NETWORK_AI_CORE,
		CAMERANET_NETWORK_AI_UPLOAD,
		CAMERANET_NETWORK_MINISAT,
		CAMERANET_NETWORK_XENOBIOLOGY,
		CAMERANET_NETWORK_TEST_CHAMBER,
		CAMERANET_NETWORK_ORDNANCE,
	)
	frame_type = /obj/item/wallframe/telescreen/rd

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/rd, 32)

/obj/item/wallframe/telescreen/rd
	name = "\improper Research Director's telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/rd

/obj/machinery/computer/security/telescreen/research
	name = "research telescreen"
	desc = "A telescreen with access to the research division's camera network."
	network = list(CAMERANET_NETWORK_RD)
	frame_type = /obj/item/wallframe/telescreen/research

/obj/item/wallframe/telescreen/research
	name = "research telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/research

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/research, 32)

/obj/machinery/computer/security/telescreen/ce
	name = "\improper Site Foreman's telescreen"
	desc = "Used for watching the engine, telecommunications and the minisat."
	network = list(CAMERANET_NETWORK_ENGINE, CAMERANET_NETWORK_TELECOMMS, CAMERANET_NETWORK_MINISAT)
	frame_type = /obj/item/wallframe/telescreen/ce

/obj/item/wallframe/telescreen/ce
	name = "\improper Site Foreman's telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/ce

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/ce, 32)

/obj/machinery/computer/security/telescreen/cmo
	name = "\improper Medical Director's telescreen"
	desc = "A telescreen with access to the medbay's camera network."
	network = list(CAMERANET_NETWORK_MEDBAY)
	frame_type = /obj/item/wallframe/telescreen/cmo

/obj/item/wallframe/telescreen/cmo
	name = "\improper Site Foreman'stelescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/cmo

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/cmo, 32)

/obj/machinery/computer/security/telescreen/vault
	name = "vault monitor"
	desc = "A telescreen that connects to the vault's camera network."
	network = list(CAMERANET_NETWORK_VAULT)
	frame_type = /obj/item/wallframe/telescreen/vault

/obj/item/wallframe/telescreen/vault
	name = "vault telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/vault

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/vault, 32)

/obj/machinery/computer/security/telescreen/ordnance
	name = "bomb test site monitor"
	desc = "A telescreen that connects to the bomb test site's camera."
	network = list(CAMERANET_NETWORK_ORDNANCE)
	frame_type = /obj/item/wallframe/telescreen/ordnance

/obj/item/wallframe/telescreen/ordnance
	name = "bomb test site telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/ordnance

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/ordnance, 32)

/obj/machinery/computer/security/telescreen/engine
	name = "engine monitor"
	desc = "A telescreen that connects to the engine's camera network."
	network = list(CAMERANET_NETWORK_ENGINE)
	frame_type = /obj/item/wallframe/telescreen/engine

/obj/item/wallframe/telescreen/engine
	name = "engine telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/engine

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/engine, 32)

/obj/machinery/computer/security/telescreen/turbine
	name = "turbine monitor"
	desc = "A telescreen that connects to the turbine's camera."
	network = list(CAMERANET_NETWORK_TURBINE)
	frame_type = /obj/item/wallframe/telescreen/turbine

/obj/item/wallframe/telescreen/turbine
	name = "turbine telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/turbine

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/turbine, 32)

/obj/machinery/computer/security/telescreen/interrogation
	name = "interrogation room monitor"
	desc = "A telescreen that connects to the interrogation room's camera."
	network = list(CAMERANET_NETWORK_INTERROGATION)
	frame_type = /obj/item/wallframe/telescreen/interrogation

/obj/item/wallframe/telescreen/interrogation
	name = "interrogation telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/interrogation

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/interrogation, 32)

/obj/machinery/computer/security/telescreen/prison
	name = "prison monitor"
	desc = "A telescreen that connects to the permabrig's camera network."
	network = list(CAMERANET_NETWORK_PRISON)
	frame_type = /obj/item/wallframe/telescreen/prison

/obj/item/wallframe/telescreen/prison
	name = "prison telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/prison

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/prison, 32)

/obj/machinery/computer/security/telescreen/auxbase
	name = "auxiliary base monitor"
	desc = "A telescreen that connects to the auxiliary base's camera."
	network = list(CAMERANET_NETWORK_AUXBASE)
	frame_type = /obj/item/wallframe/telescreen/auxbase

/obj/item/wallframe/telescreen/auxbase
	name = "auxiliary base telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/auxbase

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/auxbase, 32)

/obj/machinery/computer/security/telescreen/minisat
	name = "minisat monitor"
	desc = "A telescreen that connects to the minisat's camera network."
	network = list(CAMERANET_NETWORK_MINISAT)
	frame_type = /obj/item/wallframe/telescreen/minisat

/obj/item/wallframe/telescreen/minisat
	name = "minisat telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/minisat

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/minisat, 32)

/obj/machinery/computer/security/telescreen/aiupload
	name = "\improper AI upload monitor"
	desc = "A telescreen that connects to the AI upload's camera network."
	network = list(CAMERANET_NETWORK_AI_UPLOAD)
	frame_type = /obj/item/wallframe/telescreen/aiupload

/obj/item/wallframe/telescreen/aiupload
	name = "\improper AI upload telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/aiupload

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/aiupload, 32)

/obj/machinery/computer/security/telescreen/bar
	name = "bar monitor"
	desc = "A telescreen that connects to the bar's camera network. Perfect for checking on customers."
	network = list(CAMERANET_NETWORK_BAR)
	frame_type = /obj/item/wallframe/telescreen/bar

/obj/item/wallframe/telescreen/bar
	name = "bar telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/bar

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/bar, 32)

/obj/machinery/computer/security/telescreen/isolation
	name = "isolation cell monitor"
	desc = "A telescreen that connects to the isolation cells camera network."
	network = list(CAMERANET_NETWORK_ISOLATION)
	frame_type = /obj/item/wallframe/telescreen/bar

/obj/item/wallframe/telescreen/isolation
	name = "isolation telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/isolation

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/isolation, 32)

/obj/machinery/computer/security/telescreen/normal
	name = "security camera monitor"
	desc = "A telescreen that connects to the stations camera network."
	network = list(CAMERANET_NETWORK_SS13)
	frame_type = /obj/item/wallframe/telescreen/normal

/obj/item/wallframe/telescreen/normal
	name = "security camera telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/normal

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/normal, 32)

/obj/machinery/computer/security/telescreen/tcomms
	name = "tcomms camera monitor"
	desc = "A telescreen that connects to the tcomms camera network."
	network = list(CAMERANET_NETWORK_TELECOMMS)
	frame_type = /obj/item/wallframe/telescreen/tcomms

/obj/item/wallframe/telescreen/tcomms
	name = "tcomms camera telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/tcomms

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/tcomms, 32)

/obj/machinery/computer/security/telescreen/test_chamber
	name = "xenobiology test chamber camera monitor"
	desc = "A telescreen that connects to the xenobiology test chamber camera network."
	network = list(CAMERANET_NETWORK_XENOBIOLOGY)
	frame_type = /obj/item/wallframe/telescreen/test_chamber

/obj/item/wallframe/telescreen/test_chamber
	name = "xenobiology test chamber camera telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/test_chamber

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/test_chamber, 32)

/obj/machinery/computer/security/telescreen/engine_waste
	name = "\improper Engine Waste Monitor"
	desc = "A telescreen that connects to the engine waste camera network."
	network = list(CAMERANET_NETWORK_WASTE)
	frame_type = /obj/item/wallframe/telescreen/engine_waste

/obj/item/wallframe/telescreen/engine_waste
	name = "\improper Engine Waste telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/engine_waste

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/engine_waste, 32)

/obj/machinery/computer/security/telescreen/cargo_sec
	name = "cargo camera monitor"
	desc = "A telescreen that connects to the cargo and main station camera network."
	network = list(CAMERANET_NETWORK_SS13,
					CAMERA_NETWORK_CARGO,
					)
	frame_type = /obj/item/wallframe/telescreen/cargo_sec

/obj/item/wallframe/telescreen/cargo_sec
	name = "cargo telescreen frame"
	result_path = /obj/machinery/computer/security/telescreen/cargo_sec

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/cargo_sec, 32)

// This is used in moonoutpost19.dmm
/obj/machinery/computer/security/telescreen/moon_outpost

/obj/machinery/computer/security/telescreen/moon_outpost/research
	name = "research monitor"
	desc = "Used for monitoring the research division and the labs within."
	network = list(CAMERANET_NETWORK_MOON19_RESEARCH,
					CAMERANET_NETWORK_MOON19_XENO,
					)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/moon_outpost/research, 32)

/obj/machinery/computer/security/telescreen/moon_outpost/xenobio
	name = "xenobiology monitor"
	desc = "Used for watching the contents of the xenobiology containment pen."
	network = list(CAMERANET_NETWORK_MOON19_XENO)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/moon_outpost/xenobio, 32)

// This is used in undergroundoutpost45.dmm
/obj/machinery/computer/security/telescreen/underground_outpost

/obj/machinery/computer/security/telescreen/underground_outpost/research
	name = "research monitor"
	desc = "Used for monitoring the research division and the labs within."
	network = list(CAMERANET_NETWORK_UGO45_RESEARCH)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/underground_outpost/research, 32)

// This is used in forgottenship.dmm
/obj/machinery/computer/security/telescreen/forgotten_ship

/obj/machinery/computer/security/telescreen/forgotten_ship/sci
	name = "Cameras monitor"
	network = list(CAMERANET_NETWORK_FSCI)
	req_access = list("syndicate")

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/forgotten_ship/sci, 32)

// This is used in deepstorage.dmm
/obj/machinery/computer/security/telescreen/deep_storage

/obj/machinery/computer/security/telescreen/deep_storage/bunker
	name = "Bunker Entrance monitor"
	network = list(CAMERA_NETWORK_BUNKER)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/deep_storage/bunker, 32)

/obj/machinery/computer/security/telescreen/monastery
	name = "Monastery monitor"
	network = list(MONASTERY_CAMERA_NET)

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/computer/security/telescreen/monastery, 32)

/// A button that adds a camera network to the entertainment monitors
/obj/machinery/button/showtime
	name = "thunderdome showtime button"
	desc = "Use this button to allow entertainment monitors to broadcast the big game."
	device_type = /obj/item/assembly/control/showtime
	req_access = list()
	id = "showtime_1"

/obj/machinery/button/showtime/Initialize(mapload)
	. = ..()
	if(device)
		var/obj/item/assembly/control/showtime/ours = device
		ours.id = id

/obj/item/assembly/control/showtime
	name = "showtime controller"
	desc = "A remote controller for entertainment monitors."
	/// Stores if the show associated with this controller is active or not
	var/is_show_active = FALSE
	/// The camera network id this controller toggles
	var/tv_network_id = "thunder"
	/// The display TV show name
	var/tv_show_name = "Thunderdome"
	/// List of phrases the entertainment console may say when the show begins
	var/list/tv_starters = list(
		"Feats of bravery live now at the thunderdome!",
		"Two enter, one leaves! Tune in now!",
		"Violence like you've never seen it before!",
		"Spears! Camera! Action! LIVE NOW!",
	)
	/// List of phrases the entertainment console may say when the show ends
	var/list/tv_enders = list(
		"Thank you for tuning in to the slaughter!",
		"What a show! And we guarantee next one will be bigger!",
		"Celebrate the results with Thundermerch!",
		"This show was brought to you by Nanotrasen.",
	)

/obj/item/assembly/control/showtime/activate()
	is_show_active = !is_show_active
	say("The [tv_show_name] show has [is_show_active ? "begun" : "ended"]")
	var/announcement = is_show_active ? pick(tv_starters) : pick(tv_enders)
	for(var/obj/machinery/computer/security/telescreen/entertainment/tv as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/security/telescreen/entertainment))
		tv.update_shows(is_show_active, tv_network_id, announcement)
