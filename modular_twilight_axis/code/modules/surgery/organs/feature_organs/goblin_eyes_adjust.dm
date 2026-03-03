#define GOBLIN_EYE_IMPLANT_PER_PENALTY 2

/datum/status_effect/debuff/goblin_eye_implant
	id = "goblin_eye_implant"
	duration = -1
	alert_type = /atom/movable/screen/alert/status_effect/debuff/goblin_eye_implant
	effectedstats = list(STATKEY_PER = -GOBLIN_EYE_IMPLANT_PER_PENALTY)

/atom/movable/screen/alert/status_effect/debuff/goblin_eye_implant
	name = "Goblin Eyes"
	desc = "Implanted low-quality eyes hinder your awareness."
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

	if(!E)
		return

	if(!istype(E, /obj/item/organ/eyes/goblin) && \
	   !istype(E, /obj/item/organ/eyes/night_vision/wild_goblin) && \
	   !istype(E, /obj/item/organ/eyes/night_vision/zombie))
		return

	examine_list += span_warning("Their eyes carry a strange reddish glow, as if from a crude transplant.")

/obj/item/organ/eyes/proc/is_species_default_eye(mob/living/carbon/human/H)
	var/default_eye_type = H?.dna?.species?.organs?[ORGAN_SLOT_EYES]
	return default_eye_type && (type == default_eye_type)

/obj/item/organ/eyes/proc/should_handle_as_implanted_low_quality_eye(mob/living/carbon/human/H, initialising)
	if(!H?.ckey)
		return FALSE
	if(initialising && is_species_default_eye(H))
		return FALSE
	return TRUE

/obj/item/organ/eyes/proc/try_apply_low_quality_eye_per_penalty(mob/living/carbon/human/H)
	if(H.stat == DEAD || (H.mob_biotypes & MOB_UNDEAD))
		return
	if(!H.has_status_effect(/datum/status_effect/debuff/goblin_eye_implant))
		H.apply_status_effect(/datum/status_effect/debuff/goblin_eye_implant)

/obj/item/organ/eyes/proc/clear_low_quality_eye_penalty(mob/living/carbon/human/H)
	H.remove_status_effect(/datum/status_effect/debuff/goblin_eye_implant)

/obj/item/organ/eyes/goblin/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE, initialising)
	. = ..()
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M
	if(!should_handle_as_implanted_low_quality_eye(H, initialising))
		return

	if(!H.GetComponent(/datum/component/goblin_eye_implant_examine))
		H.AddComponent(/datum/component/goblin_eye_implant_examine)
	try_apply_low_quality_eye_per_penalty(H)

/obj/item/organ/eyes/goblin/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M
	if(!H.ckey)
		return

	qdel(H.GetComponent(/datum/component/goblin_eye_implant_examine))
	clear_low_quality_eye_penalty(H)

/obj/item/organ/eyes/night_vision/wild_goblin/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE, initialising)
	. = ..()
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M
	if(!should_handle_as_implanted_low_quality_eye(H, initialising))
		return
	try_apply_low_quality_eye_per_penalty(H)

/obj/item/organ/eyes/night_vision/wild_goblin/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M
	if(!H.ckey)
		return
	clear_low_quality_eye_penalty(H)

/obj/item/organ/eyes/night_vision/zombie/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = FALSE, initialising)
	. = ..()
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M
	if(!should_handle_as_implanted_low_quality_eye(H, initialising))
		return
	try_apply_low_quality_eye_per_penalty(H)

/obj/item/organ/eyes/night_vision/zombie/Remove(mob/living/carbon/M, special = FALSE)
	. = ..()
	if(!ishuman(M))
		return

	var/mob/living/carbon/human/H = M
	if(!H.ckey)
		return
	clear_low_quality_eye_penalty(H)

#undef GOBLIN_EYE_IMPLANT_PER_PENALTY
