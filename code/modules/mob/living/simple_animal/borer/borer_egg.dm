/obj/structure/borer_egg
	anchored = 1
	density = 0
	desc = "A strange egg. It glows sometimes."
	name = "egg"
	icon = 'icons/mob/animal.dmi'
	icon_state = "borer_egg"
	var/health = 100
	layer = TURF_LAYER

/obj/structure/borer_egg/New()
	..()
	spawn(rand(1800, 3000))
		processing_objects.Add(src)

/obj/structure/borer_egg/process()

	var/mob/dead/observer/ghost
	for(var/mob/dead/observer/O in src.loc)
		if(!O.client)	continue
		if(O.mind && O.mind.current && O.mind.current.stat != DEAD)	continue
		ghost = O
		break

	var/turf/location = get_turf(src)
	var/datum/gas_mixture/environment = location.return_air()
	if(environment.toxins >= MOLES_PLASMA_VISIBLE && ghost)
		var/response = alert(ghost, "This egg is ready to hatch. Do you want to be a cortical borer?",, "Yes", "No")
		if(response == "Yes")
			var/mob/living/simple_animal/borer/B = new /mob/living/simple_animal/borer
			B.loc = src.loc
			B.key = ghost.key
			qdel(src)
	else if(environment.toxins >= MOLES_PLASMA_VISIBLE || ghost)
		if(icon_state != "borer_egg_pulsing")
			icon_state = "borer_egg_pulsing"

	else
		if(icon_state != "borer_egg_grown")
			icon_state = "borer_egg_grown"


/obj/structure/borer_egg/attackby(obj/item/I, mob/user)
	if(I.attack_verb.len)
		visible_message("<span class='danger'>[src] has been [pick(I.attack_verb)] with [I] by [user].</span>")
	else
		visible_message("<span class='danger'>[src] has been attacked with [I] by [user]!</span>")

	var/damage = I.force / 4
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I

		if(WT.remove_fuel(0, user))
			damage = 15
			playsound(loc, hitnoise, 100, 1)

	health -= damage
	healthcheck()

/obj/structure/borer_egg/bullet_act(obj/item/projectile/Proj)
	health -= Proj.damage
	..()
	healthcheck()

/obj/structure/borer_egg/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 500)
		health -= 5
		healthcheck()

/obj/structure/borer_egg/attack_hand(mob/user)
	user << "<span class='notice'>It feels slimy.</span>"

/obj/structur/borer_egg/proc/healthcheck()
	if(health <= 0)
		qdel(src)