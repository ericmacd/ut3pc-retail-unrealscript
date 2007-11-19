﻿/**
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */


class UTDmgType_PaladinProximityExplosion extends UTDamageType
	abstract;

defaultproperties
{
	KillStatsName=KILLS_PALADINEXPLOSION
	DeathStatsName=DEATHS_PALADINEXPLOSION
	SuicideStatsName=SUICIDES_PALADINEXPLOSION
	DamageWeaponClass=class'UTVWeap_PaladinGun'
	bThrowRagdoll=true
}
