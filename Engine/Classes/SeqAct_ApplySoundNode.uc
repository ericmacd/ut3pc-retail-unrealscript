﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class SeqAct_ApplySoundNode extends SequenceAction
	native(Sequence);



var() SoundCue PlaySound;
var() editinline SoundNode ApplyNode;

defaultproperties
{
	ObjName="Apply Sound Node"
	ObjCategory="Sound"
}
