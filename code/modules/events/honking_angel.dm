/datum/round_event_control/honking_angel
	name = "Honking Angel"
	typepath = /datum/round_event/honking_angel
	max_occurrences = 1
	needs_ghosts = 1
	rating = list(
				"Gameplay"	= 70,
				"Dangerous"	= 60
				)

/datum/round_event/honking_angel
	var/spawncount = 1
	var/successSpawn = 0	//So we don't make a command report if nothing gets spawned.

/datum/round_event/honking_angel/setup()
	spawncount = rand(5, 8)

/datum/round_event/honking_angel/announce()
	if(successSpawn)
		priority_announce("Space-time anomalies detected on the station. There is no additional data.", "Anomaly Alert", 'sound/AI/spanomalies.ogg')

/datum/round_event/honking_angel/tick_queue()
	var/list/candidates = get_candidates(BE_ANGEL)
	if(candidates.len)
		unqueue()


/datum/round_event/honking_angel/start()
	var/list/floors = list()
	spawncount = pick(1,1,1,2,2,3)
	for(var/turf/simulated/floor/temp_floor in world)
		if(temp_floor.loc.z == 1 && !temp_floor.lighting_lumcount >= 0.50)
			floors += temp_floor

//
	var/list/candidates = get_candidates(BE_ANGEL)

	if(!candidates.len && events.queue_ghost_events && !loopsafety)
		queue()
		return

	while(spawncount > 0 && floors.len && candidates.len)
		var/obj/floor = pick_n_take(floors)
		var/client/C = pick_n_take(candidates)
		var/F = floor.loc

		//this is to give 10 tries to find a floor tile.
		var/i = 0
		while (floor.loc.x == 1 && floor.loc.y == 1 && i <= 9)
			floor = pick_n_take(floors)
			F = floor.loc
			i++
			if (i == 9 && floor.loc.x == 1 && floor.loc.y == 1)
				return //give up
		//////
		var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
		s.set_up(4, 2, get_turf(F))
		s.start()
		var/mob/living/simple_animal/hostile/weeping_honk/M = new(F)
		//world << {"\red <b>[F]</b>"}
		//var/M = new /mob/living/simple_animal/hostile/weeping_honk(vent.loc)
		if (C)
			M.key = C.key

		spawncount--
		successSpawn = 1
//