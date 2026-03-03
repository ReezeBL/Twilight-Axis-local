#define GOBLIN_EYE_IMPLANT_PER_PENALTY 2
#define ZOMBIE_EYE_IMPLANT_PER_PENALTY 6

/datum/status_effect/debuff/goblin_eye_implant
	id = "goblin_eye_implant"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/debuff/goblin_eye_implant
	effectedstats = list(STATKEY_PER = -GOBLIN_EYE_IMPLANT_PER_PENALTY)

/datum/status_effect/debuff/zombie_eye_implant
	id = "zombie_eye_implant"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/debuff/zombie_eye_implant
	effectedstats = list(STATKEY_PER = -ZOMBIE_EYE_IMPLANT_PER_PENALTY)

/atom/movable/screen/alert/status_effect/debuff/goblin_eye_implant
	name = "Goblin Eyes"
	desc = "These are not your eyes. They were forced into your skull by crude hands, and they do not see the world as you once did."
	icon_state = "debuff"

/atom/movable/screen/alert/status_effect/debuff/zombie_eye_implant
	name = "Rot-Touched Eyes"
	desc = "Dead flesh stares through your skull. Your vision sharpens in darkness, but something vital has been lost."
	icon_state = "debuff"

/datum/component/goblin_eye_implant_examine

/datum/component/goblin_eye_implant_examine/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/goblin_eye_implant_examine/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_PARENT_EXAMINE)
	return ..()

/datum/component/goblin_eye_implant_examine/proc/on_examine(mob/living/carbon/human/source, mob/user, list/examine_list)
	if(!source?.ckey)
		return

	var/skipface = (source.wear_mask && (source.wear_mask.flags_inv & HIDEFACE)) || \
				   (source.head && (source.head.flags_inv & HIDEFACE))
	if(skipface)
		return

	var/obj/item/organ/eyes/E = source.getorganslot(ORGAN_SLOT_EYES)
	if(!E || !E.status_type)
		return

	if(E.status_type == /datum/status_effect/debuff/goblin_eye_implant)
		examine_list += span_warning("A faint crimson glint flickers in their gaze — sharp, foreign, and wrong.")
	else if(E.status_type == /datum/status_effect/debuff/zombie_eye_implant)
		examine_list += span_warning("A dull, corpse-like sheen clouds their eyes — as if something dead stares back from within.")

/obj/item/organ/eyes
	var/low_quality_eye = FALSE
	var/status_type = null
	var/ignore_if_undead = TRUE

/obj/item/organ/eyes/goblin
	low_quality_eye = TRUE
	status_type = /datum/status_effect/debuff/goblin_eye_implant

/obj/item/organ/eyes/night_vision/wild_goblin
	low_quality_eye = TRUE
	status_type = /datum/status_effect/debuff/goblin_eye_implant

/obj/item/organ/eyes/night_vision/nightmare
	low_quality_eye = TRUE
	status_type = /datum/status_effect/debuff/goblin_eye_implant

/obj/item/organ/eyes/night_vision/zombie
	low_quality_eye = TRUE
	status_type = /datum/status_effect/debuff/zombie_eye_implant
	ignore_if_undead = TRUE

/obj/item/organ/eyes/proc/is_species_default_eye(mob/living/carbon/human/H)
	var/default_eye_type = H?.dna?.species?.organs?[ORGAN_SLOT_EYES]
	return default_eye_type && (type == default_eye_type)

/obj/item/organ/eyes/proc/should_handle_as_implanted_low_quality_eye(mob/living/carbon/human/H, initialising)
	if(!H?.ckey)
		return FALSE
	if(initialising && is_species_default_eye(H))
		return FALSE
	return TRUE

/obj/item/organ/eyes/proc/apply_eye_penalty(mob/living/carbon/human/H)
	if(ignore_if_undead && (H.mob_biotypes & MOB_UNDEAD))
		return

	if(H.stat == DEAD)
		return

	if(!status_type)
		return

	if(!H.has_status_effect(status_type))
		H.apply_status_effect(status_type)

/obj/item/organ/eyes/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE, initialising)
	. = ..()
	if(!ishuman(M) || !low_quality_eye)
		return

	var/mob/living/carbon/human/H = M
	if(!should_handle_as_implanted_low_quality_eye(H, initialising))
		return

	if(!H.GetComponent(/datum/component/goblin_eye_implant_examine))
		H.AddComponent(/datum/component/goblin_eye_implant_examine)

	apply_eye_penalty(H)

/obj/item/organ/eyes/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	if(!ishuman(M) || !low_quality_eye)
		return

	var/mob/living/carbon/human/H = M
	if(!H.ckey)
		return

	qdel(H.GetComponent(/datum/component/goblin_eye_implant_examine))
	if(status_type)
		H.remove_status_effect(status_type)

#undef GOBLIN_EYE_IMPLANT_PER_PENALTY
#undef ZOMBIE_EYE_IMPLANT_PER_PENALTY