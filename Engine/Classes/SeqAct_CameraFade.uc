﻿class SeqAct_CameraFade extends SequenceAction
	native(Sequence);

/** Color to use as the fade */
var() color FadeColor;
/** Range of alpha to fade, FadeAlpha.X + ((1.f - FadeTimeRemaining/FadeTime) * (FadeAlpha.Y - FadeAlpha.X)) */
var() vector2d FadeAlpha;
/** How long to fade from FadeAlpha.X to FadeAlpha.Y */
var() float FadeTime;
/** Should the fade persist? */
var() bool bPersistFade;

/** Time left before reaching full alpha */
var transient float FadeTimeRemaining;
/** List of cameras this action is applied to */
var transient array<Camera> CachedCameras;

;

defaultproperties
{
	ObjName="Fade"
	ObjCategory="Camera"

	bLatentExecution=TRUE
	bAutoActivateOutputLinks=FALSE

	FadeAlpha=(X=0.f,Y=1.f)
	FadeTime=1.f
	bPersistFade=TRUE

	OUtputLinks(0)=(LinkDesc="Out")
	OUtputLinks(1)=(LinkDesc="Finished")
}