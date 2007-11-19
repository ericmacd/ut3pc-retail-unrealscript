﻿/**
 * Modifies the behavior, appearance, available events, or actions for a single widget.  Every widget has at last two
 * UIStates - enabled and disabled, but can have as many as necessary.  Other common widget states might be focused,
 * active, pressed, dragging (i.e. drag-n-drop), or selected.
 *
 * Examples of things a UIState may do include replacing the widget's image or changing the appearance of the widget in
 * some other fashion, such as brightening, adding a bevel, etc.
 *
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 */
class UIState extends UIRoot
	native(inherit)
	abstract
	implements(UIEventContainer)
	editinlinenew;

/**
 * Contains the events, actions, and variables that are only available while this state is active.
 *
 * Marked noimport because UUISceneFactoryText uses accessor functions to create the creates sequences for pasted objects, so
 * we don't want to overwrite the value of the pasted widget's StateSequence with the value from the paste text.
 */
var	instanced	noimport	UIStateSequence			StateSequence;

/**
 * The list of events that should be de-activated while this UIState is in scope.  When the state becomes active, it will
 * remove these events from the widget's list of active events, and will prevent any other UIStates from activating that
 * event type as long as this UIState is still active.
 */
//@todo - figure out the best data structure for exposing this
//var()	editinline				array<class<UIEvent> >	EventsToSuppress;

/**
 * The list of input keys (and their associated actions) to activate when this state becomes active.  When the state becomes
 * active, any input actions in this list will be added to the widget's input processing event.  If the widget does not have
 * a input processing event, one is automatically created.  When this state is deactivated, the input actions in this list are
 * removed from the widget's event processor.
 */
var							array<InputKeyAction>	StateInputActions;

/**
 * Contains the input keys that the designer wants to remove from this state's supported input keys.  Only those input actions
 * which are generated from a default input action [declared in a widget class's default properties] need to be in this array.
 * Required to prevent the code that instances default input key actions that were added by the programmer after the designer
 * placed this widget from re-instancing input keys that the designer has removed from this state's list of supported input keys.
 */
var							array<InputKeyAction>	DisabledInputActions;

/**
 * The list of input keys (and their associated actions) that should be disabled while this UIState is in scope. When the state
 * becomes active, it will remove these input actions from the widget's input processing event.  When this state is deactivated,
 * it will readd these input actions to the widget's input processor
 */
//var()	editinline				array<InputKeyAction>	InputActionsToSuppress;

/**
 * Allows UIStates to specify a particular mouse cursor that should be used while this state is active.  Can be overridden
 * by the widget that owns this UIState, and must correspond to a cursor resource name from the active skin's MouseCursorMap.
 */
var()							name				MouseCursorName;

/**
 * A bitmask representing the indexes [into the Engine.GamePlayers array] that this state has been activated for.  The value
 * is generated by left bitshifting by the index of the player.
 * A value of 1 << 1 indicates that this state was activated by the player at index 1.  So value of 3 means that this state
 * is active for the players at indexes 0 and 1.
 */
var	transient					byte				PlayerIndexMask;

/**
 * Controls where the state will be inserted into the owning widget's StateStack array.  States with a higher value will
 * always be inserted after states with a lower value.
 */
var	transient	const			byte				StackPriority;



/**
 * Determines whether this state can be used by the widget class specified.  Only used in the UI editor to remove
 * unsupported states from the various controls and menus.
 */
event bool IsWidgetClassSupported( class<UIScreenObject> WidgetClass )
{
	return WidgetClass != None;
}

/**
 * Determines whether this state has been activated for the specified player index
 *
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] of the player to check for
 *
 * @return	TRUE if this state has been activated for the specified player.
 */
native final function bool IsActiveForPlayer( int PlayerIndex ) const;

/**
 * Activate this state for the specified target.
 *
 * @param	Target			the widget that is activating this state.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
 *
 * @return	TRUE to allow this state to be activated for the specified Target.
 */
event bool ActivateState( UIScreenObject Target, int PlayerIndex )
{
	return true;
}

/**
 * Deactivate this state for the specified target.
 *
 * @param	Target			the widget that is deactivating this state.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
 *
 * @return	TRUE to allow this state to be deactivated for the specified Target.
 */
event bool DeactivateState( UIScreenObject Target, int PlayerIndex )
{
	return true;
}

/**
 * Notification that Target has made this state its active state.
 *
 * @param	Target			the widget that activated this state.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
 * @param	bPushedState	TRUE when this state has just been added to the owning widget's StateStack; FALSE if this state
 *							is being activated for additional players in split-screen
 */
event OnActivate( UIScreenObject Target, int PlayerIndex, bool bPushedState );

/**
 * Notification that Target has just deactivated this state.
 *
 * @param	Target			the widget that deactivated this state.
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
 * @param	bPoppedState	TRUE when this state has been removed from the owning widget's StateStack; FALSE if this state
 *							is still active for at least one player (i.e. in split-screen)
 */
event OnDeactivate( UIScreenObject Target, int PlayerIndex, bool bPoppedState );

/**
 * Allows states currently in a widget's StateStack to prevent the widget from entering a new state.  This
 * function is only called for states currently in the widget's StateStack.
 *
 * @param	Target			the widget that wants to enter the new state
 * @param	NewState		the new state that widget wants to enter
 * @param	PlayerIndex		the index [into the Engine.GamePlayers array] for the player that generated this call
 *
 * @return	TRUE if the widget should be allowed to enter the state specified.
 *
 * @fixme splitscreen
 */
event bool IsStateAllowed( UIScreenObject Target, UIState NewState, int PlayerIndex )
{
	// default behavior is to simply prevent duplicate states from being in the target's StateStack, unless we're activating
	// a state for another player
//	return NewState != Self || (PlayerIndexMask & (1 << PlayerIndex)) == 0;

	// attempting to add a state which is already in the state stack is now handled differently
	return true;
}

/* == UIEventContainer interface == */
/**
 * Retrieves the UIEvents contained by this container.
 *
 * @param	out_Events	will be filled with the UIEvent instances stored in by this container
 * @param	LimitClass	if specified, only events of the specified class (or child class) will be added to the array
 */
native final function GetUIEvents( out array<UIEvent> out_Events, optional class<UIEvent> LimitClass );

/**
 * Adds a new SequenceObject to this containers's list of ops
 *
 * @param	NewObj		the sequence object to add.
 * @param	bRecurse	if TRUE, recursively add any sequence objects attached to this one
 *
 * @return	TRUE if the object was successfully added to the sequence.
 *
 */
native final function bool AddSequenceObject( SequenceObject NewObj, optional bool bRecurse );

/**
 * Removes the specified SequenceObject from this container's list of ops.
 *
 * @param	ObjectToRemove	the sequence object to remove
 */
native final function RemoveSequenceObject( SequenceObject ObjectToRemove );

/**
 * Removes the specified SequenceObjects from this container's list of ops.
 *
 * @param	ObjectsToRemove		the objects to remove from this sequence
 */
native final function RemoveSequenceObjects( const out array<SequenceObject> ObjectsToRemove );

DefaultProperties
{
	MouseCursorName=Arrow
}