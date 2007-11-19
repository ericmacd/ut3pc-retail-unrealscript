﻿/**
 * This event is activated when the value of a UIComboBox is changed.
 *
 * Copyright 2007 Epic Games, Inc. All Rights Reserved
 */
class UIEvent_ComboboxValueChanged extends UIEvent_ValueChanged
	native(inherit);

/**
 * Determines whether this class should be displayed in the list of available ops in the UI's kismet editor.
 *
 * @param	TargetObject	the widget that this SequenceObject would be attached to.
 *
 * @return	TRUE if this sequence object should be available for use in the UI kismet editor
 */
event bool IsValidUISequenceObject( optional UIScreenObject TargetObject )
{
	return TargetObject == None || UIComboBox(TargetObject) != None || TargetObject.ContainsChildOfClass(class'UIComboBox');
}

DefaultProperties
{
	ObjName="Combobox Value Changed"

	OutputLinks(0)=(LinkDesc="Text Changed")
	OutputLinks(1)=(LinkDesc="Item Selected")

	VariableLinks.Add((ExpectedType=class'SeqVar_String',LinkDesc="Text Value",bWriteable=false))
	VariableLinks.Add((ExpectedType=class'SeqVar_Int',LinkDesc="Current Item",bWriteable=false))
	VariableLinks.Add((ExpectedType=class'SeqVar_Int',LinkDesc="Current List Index",bWriteable=false,bHidden=false))
}
