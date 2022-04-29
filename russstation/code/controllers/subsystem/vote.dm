/datum/controller/subsystem/vote/var/transit_timer

/datum/controller/subsystem/vote/OnConfigLoad()
	if(CONFIG_GET(flag/transfer_vote))
		var/initial_delay = CONFIG_GET(number/transfer_delay_initial)
		if(initial_delay > world.time)
			set_transfer_timer(initial_delay - world.time)
		else
			set_transfer_timer(CONFIG_GET(number/transfer_delay_subsequent))

/datum/controller/subsystem/vote/proc/set_transfer_timer(timing)
	if(transit_timer)
		deltimer(transit_timer)
	transit_timer = addtimer(CALLBACK(src, .proc/attempt_transfer_vote), timing, TIMER_STOPPABLE)

/datum/controller/subsystem/vote/proc/attempt_transfer_vote()
	if(SSshuttle.emergency.mode == SHUTTLE_IDLE || SSshuttle.emergency.mode == SHUTTLE_RECALL)
		initiate_vote("crew transfer","the server")
	else
		// recheck to see if the shuttle is no longer busy after ten minutes
		set_transfer_timer(10 MINUTES)

/datum/controller/subsystem/vote/proc/shuttlecall()
	var/obj/docking_port/mobile/emergency/e_shuttle = SSshuttle.emergency
	// check to prevent the vote resetting an already called shuttle
	if(e_shuttle.mode == SHUTTLE_IDLE || e_shuttle.mode == SHUTTLE_RECALL)
		e_shuttle.request()
		SSshuttle.emergency_no_recall = TRUE
		message_admins("The emergency shuttle has been requested because of a successful transfer vote")
	else
		to_chat(world, span_boldannounce("Notice: The crew transfer vote has failed because the shuttle is unavailable"))
