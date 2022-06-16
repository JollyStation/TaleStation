/datum/lua_editor
	var/datum/lua_state/current_state

	/// Code imported from the user's system
	var/imported_code

	/// Arguments for a function call or coroutine resume
	var/list/arguments = list()

/datum/lua_editor/New(state, _quick_log_index)
	. = ..()
	if(state)
		current_state = state
		LAZYADDASSOCLIST(SSlua.editors, "\ref[current_state]", src)

/datum/lua_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LuaEditor", "Lua")
		ui.set_autoupdate(FALSE)
		ui.open()

/datum/lua_editor/Destroy(force, ...)
	. = ..()
	if(current_state)
		LAZYREMOVEASSOC(SSlua.editors, "\ref[current_state]", src)

/datum/lua_editor/ui_state(mob/user)
	return GLOB.debug_state

/// Returns a copy of the list where any element that is a datum or the world is converted into a ref
/proc/refify_list(list/target_list)
	var/list/ret = list()
	for(var/i in 1 to target_list.len)
		var/key = target_list[i]
		var/new_key = key
		if(isdatum(key))
			new_key = "[key] [REF(key)]"
		else if(key == world)
			new_key = "world [REF(world)]"
		else if(islist(key))
			new_key = refify_list(key)
		var/value
		if(istext(key) || islist(key) || isdatum(key) || key == world)
			value = target_list[key]
		if(isdatum(value))
			value = "[value] [REF(value)]"
		else if(value == world)
			value = "world [REF(world)]"
		else if(islist(value))
			value = refify_list(value)
		var/list/to_add = list(new_key)
		if(value)
			to_add[new_key] = value
		ret += to_add
	return ret

/**
 * Converts a list into a list of assoc lists of the form ("key" = key, "value" = value)
 * so that list keys that are themselves lists can be fully json-encoded
 */
/proc/kvpify_list(list/target_list, depth = INFINITY)
	var/list/ret = list()
	for(var/i in 1 to target_list.len)
		var/key = target_list[i]
		var/new_key = key
		if(islist(key) && depth)
			new_key = kvpify_list(key, depth-1)
		var/value
		if(istext(key) || islist(key) || isdatum(key) || key == world)
			value = target_list[key]
		if(islist(value) && depth)
			value = kvpify_list(value, depth-1)
		if(value)
			ret += list(list("key" = new_key, "value" = value))
		else
			ret += list(list("key" = i, "value" = new_key))
	return ret

/datum/lua_editor/ui_static_data(mob/user)
	var/list/data = list()
	var/raw_documentation = file2text("code/modules/admin/verbs/lua/README.md")
	var/escaped_documentation = replacetext(raw_documentation, "_", "\\_") // the markdown parser doesn't play nice with the unescaped underscores
	data["documentation"] = parsemarkdown_basic(escaped_documentation)
	return data

/datum/lua_editor/ui_data(mob/user)
	var/list/data = list()
	data["noStateYet"] = !current_state
	if(current_state)
		current_state.get_globals()
		if(current_state.log)
			data["stateLog"] = kvpify_list(refify_list(current_state.log))
		data["tasks"] = current_state.get_tasks()
		if(current_state.globals)
			data["globals"] = kvpify_list(refify_list(current_state.globals))
	data["states"] = SSlua.states
	data["callArguments"] = kvpify_list(refify_list(arguments))
	return data

/datum/lua_editor/proc/traverse_list(list/path, list/root, traversal_depth_offset = 0)
	var/top_affected_list_depth = LAZYLEN(path)-traversal_depth_offset // The depth of the element to get
	if(top_affected_list_depth)
		var/list/current_list = root
		// We kvpify the list to the depth of the element to get - this allows us to reach list elements contained within a assoc list's key
		var/list/path_list = kvpify_list(current_list, top_affected_list_depth-1)
		while(LAZYLEN(path) > traversal_depth_offset)
			// Navigate to the index of the next path element within the current path element
			var/list/path_element = popleft(path)
			var/list/list_element = path_list[path_element["index"]]

			// Enter the next path element - be it the key or the value
			switch(path_element["type"])
				if("key")
					path_list = list_element["key"]
				if("value")
					path_list = list_element["value"]
				else
					to_chat(usr, span_warning("invalid path element type \[[path_element["type"]]] for argument move (expected \"key\" or \"value\""))
					return
			// The element we are entering SHOULD be a list
			if(!islist(path_list))
				to_chat(usr, span_warning("invalid path element \[[path_list]] for argument move (expected a list)"))
				return
			current_list = path_list
		return current_list
	else
		return root

/datum/lua_editor/ui_act(action, list/params)
	. = ..()
	if(.)
		return
	if(!check_rights_for(usr.client, R_DEBUG))
		return
	switch(action)
		if("newState")
			var/state_name = params["name"]
			var/datum/lua_state/new_state = new(state_name)
			SSlua.states += new_state
			LAZYREMOVEASSOC(SSlua.editors, "\ref[current_state]", src)
			current_state = new_state
			LAZYADDASSOCLIST(SSlua.editors, "\ref[current_state]", src)
			return TRUE
		if("switchState")
			var/state_index = params["index"]
			LAZYREMOVEASSOC(SSlua.editors, "\ref[current_state]", src)
			current_state = SSlua.states[state_index]
			LAZYADDASSOCLIST(SSlua.editors, "\ref[current_state]", src)
			return TRUE
		if("runCode")
			var/code = params["code"]
			current_state.load_script(code)
			return TRUE
		if("moveArgUp")
			var/list/path = params["path"]
			var/list/target_list = traverse_list(path, arguments, traversal_depth_offset = 1)
			var/index = popleft(path)["index"]
			target_list.Swap(index-1, index)
			return TRUE
		if("moveArgDown")
			var/list/path = params["path"]
			var/list/target_list = traverse_list(path, arguments, traversal_depth_offset = 1)
			var/index = popleft(path)["index"]
			target_list.Swap(index, index+1)
			return TRUE
		if("removeArg")
			var/list/path = params["path"]
			var/list/target_list = traverse_list(path, arguments, traversal_depth_offset = 1)
			var/index = popleft(path)["index"]
			target_list.Cut(index, index+1)
			return TRUE
		if("addArg")
			var/list/path = params["path"]
			var/list/target_list = traverse_list(path, arguments)
			if(target_list != arguments)
				usr?.client?.mod_list_add(target_list, null, "a lua editor", "arguments")
			else
				var/list/vv_val = usr?.client?.vv_get_value(restricted_classes = list(VV_RESTORE_DEFAULT))
				var/class = vv_val["class"]
				if(!class)
					return
				LAZYADD(arguments, list(vv_val["value"]))
			return TRUE
		if("callFunction")
			var/list/recursive_indices = params["indices"]
			var/list/current_list = kvpify_list(current_state.globals)
			var/function = list()
			while(LAZYLEN(recursive_indices))
				var/index = popleft(recursive_indices)
				var/list/element = current_list[index]
				var/key = element["key"]
				var/value = element["value"]
				if(!(istext(key) || isnum(key)))
					to_chat(usr, span_warning("invalid key \[[key]] for function call (expected text or num)"))
					return
				function += key
				if(islist(value))
					current_list = value
				else
					var/regex/function_regex = regex("^function: 0x\[0-9a-fA-F]+$")
					if(function_regex.Find(value))
						break
					to_chat(usr, span_warning("invalid path element \[[value]] for function call (expected list or text matching [function_regex])"))
					return
			current_state.call_function(arglist(list(function) + arguments))
			arguments.Cut()
			return TRUE
		if("resumeTask")
			var/task_index = params["index"]
			SSlua.queue_resume(current_state, task_index, arguments)
			arguments.Cut()
			return TRUE
		if("killTask")
			var/task_info = params["info"]
			SSlua.kill_task(current_state, task_info)
			return TRUE
		if("vvReturnValue")
			var/log_entry_index = params["entryIndex"]
			var/list/log_entry = current_state.log[log_entry_index]
			var/thing_to_debug = traverse_list(params["tableIndices"], log_entry["param"])
			INVOKE_ASYNC(usr.client, /client.proc/debug_variables, thing_to_debug)
			return
		if("vvGlobal")
			var/thing_to_debug = traverse_list(params["indices"], current_state.globals)
			INVOKE_ASYNC(usr.client, /client.proc/debug_variables, thing_to_debug)
			return
		if("clearArgs")
			arguments.Cut()
			return TRUE

/datum/lua_editor/ui_close(mob/user)
	. = ..()
	qdel(src)

/client/proc/open_lua_editor()
	set name = "Open Lua Editor"
	set category = "Debug"
	if(!check_rights_for(src, R_DEBUG))
		return
	if(SSlua.initialized != TRUE)
		to_chat(usr, span_warning("SSlua is not initialized!"))
		return
	var/datum/lua_editor/editor = new()
	editor.ui_interact(usr)
