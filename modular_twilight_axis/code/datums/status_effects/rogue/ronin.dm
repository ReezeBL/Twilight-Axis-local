#define RONIN_RYU_BLEED_TICK   (1 SECONDS)
#define RONIN_RYU_BLEED_MAXT   8
#define RONIN_RYU_BLEED_DMG    0.6   // базовый урон в тик (подкрути)

/datum/status_effect/debuff/ronin_ryu_bleed
	id = "ronin_ryu_bleed"
	status_type = STATUS_EFFECT_REFRESH
	tick_interval = RONIN_RYU_BLEED_TICK
	duration = 6 SECONDS
	alert_type = null

	var/stacks = 1

/datum/status_effect/debuff/ronin_ryu_bleed/on_apply(new_stacks = 1, new_duration = 6 SECONDS)
	. = ..()
	stacks = clamp(max(stacks, new_stacks), 1, RONIN_RYU_BLEED_MAXT)
	if(new_duration)
		duration = new_duration
	return TRUE

/datum/status_effect/debuff/ronin_ryu_bleed/refresh(new_stacks = 1, new_duration = 6 SECONDS)
	. = ..()
	if(QDELETED(src))
		return
	stacks = clamp(stacks + new_stacks, 1, RONIN_RYU_BLEED_MAXT)
	if(new_duration)
		duration = max(duration, new_duration)

/datum/status_effect/debuff/ronin_ryu_bleed/tick()
	. = ..()
	if(!owner || QDELETED(owner))
		return

	// лёгкий DoT по brute. Если у вас есть отдельный “bleed” пайплайн — заменишь тут.
	var/dmg = RONIN_RYU_BLEED_DMG * stacks
	if(isnum(dmg) && dmg > 0)
		owner.adjustBruteLoss(dmg)

#undef RONIN_RYU_BLEED_TICK
#undef RONIN_RYU_BLEED_MAXT
#undef RONIN_RYU_BLEED_DMG
