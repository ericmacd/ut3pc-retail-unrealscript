﻿/**
 * Copyright 1998-2007 Epic Games, Inc. All Rights Reserved.
 *
 * Main Menu Scene for UT3.
 */

class UTUIFrontEnd_MainMenu extends UTUIFrontEnd_BasicMenu;

const MAINMENU_OPTION_CAMPAIGN = 0;
const MAINMENU_OPTION_INSTANTACTION = 1;
const MAINMENU_OPTION_MULTIPLAYER = 2;
const MAINMENU_OPTION_COMMUNITY = 3;
const MAINMENU_OPTION_SETTINGS = 4;
const MAINMENU_OPTION_EXIT = 5;

/** If there isn't an existing campaign go here */
var string	CampaignStartScene;

/** If there is an existing campaign go here */
var string	CampaignContinueScene;

/** Reference to the instant action scene. */
var string	InstantActionScene;

/** Reference to the multiplayer scene. */
var string	MultiplayerScene;

/** Reference to the community scene. */
var string	CommunityScene;

/** Reference to the settings scene. */
var string	SettingsScene;

/** Reference to the Login screen. */
var string	LoginScreenScene;

var string DemoSellScene;

/** Reference to the modal message box. */
var transient UTUIScene_MessageBox MessageBoxReference;

/** Index of the player that is currently logging out. */
var transient int LogoutPlayerIndex;

/** Whether or not the logout was successful. */
var transient bool bLogoutWasSuccessful;

`include(Core/Globals.uci)

/** Callback for when the show animation has completed for this scene. */
function OnMainRegion_Show_UIAnimEnd(UIObject AnimTarget, int AnimIndex, UIAnimationSeq AnimSeq)
{
	local string OutStringValue;
	local GameUISceneClient GameSceneClient;

	`log(`location@`showobj(AnimTarget)@`showvar(AnimIndex)@`showobj(AnimSeq),,'RONDEBUG');
	Super.OnMainRegion_Show_UIAnimEnd(AnimTarget, AnimIndex, AnimSeq);

	// AnimIndex of 0 corresponds to the 'SceneShowInitial' animation
	if ( AnimIndex == 0 )
	{
		GameSceneClient = GetSceneClient();
		if ( GameSceneClient != None )
		{
			GameSceneClient.RestoreMenuProgression(Self);
		}

		// See if we should show the user the login screen.
		GetDataStoreStringValue("<Registry:ShownLoginScreen>", OutStringValue);
		if(OutStringValue!="1")
		{
			//@todo - this should be removed and we should have an option on the "connection lost" menu for logging
			// in if we're no longer logged in.
			if(!IsConsole())
			{
				if(IsLoggedIn(INDEX_NONE)==FALSE)
				{
					OpenSceneByName(LoginScreenScene, true);
				}
			}
		}

		SetDataStoreStringValue("<Registry:ShownLoginScreen>", "1");
		CheckForFrontEndError();
	}
}

/** PostInitialize event - Sets delegates for the scene. */
event PostInitialize( )
{
	Super.PostInitialize();
}

event SceneActivated(bool bInitialActivation)
{
	Super.SceneActivated(bInitialActivation);

	`log(`location@`showvar(bInitialActivation),,'RONDEBUG');
	if ( !bInitialActivation )
	{
		MenuList.SetFocus(None);
		SetupButtonBar();
	}
}

/** Setup the scene's buttonbar. */
function SetupButtonBar()
{
	ButtonBar.Clear();
	ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Select>", OnButtonBar_Select);

	if(IsConsole(CONSOLE_Xbox360))
	{
		ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.Profiles>", OnButtonBar_Login);
	}
	else if(!IsConsole())
	{
		if(IsLoggedIn(INDEX_NONE))
		{
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.LogoutMainMenu>", OnButtonBar_Logout);
		}
		else
		{
			ButtonBar.AppendButton("<Strings:UTGameUI.ButtonCallouts.LoginMainMenu>", OnButtonBar_Login);
		}
	}
}

/**
 * Executes a action based on the currently selected menu item.
 */
function OnSelectItem(int PlayerIndex=0)
{
	local int SelectedItem;

	SelectedItem = MenuList.GetCurrentItem();

	switch(SelectedItem)
	{
		case MAINMENU_OPTION_CAMPAIGN:
			StartCampaign(PlayerIndex);
			break;

		case MAINMENU_OPTION_INSTANTACTION:
			OpenSceneByName(InstantActionScene);
			break;

		case MAINMENU_OPTION_MULTIPLAYER:
			if ( CheckLinkConnectionAndError() )
			{
				OpenSceneByName(MultiplayerScene);
			}
			break;

		case MAINMENU_OPTION_COMMUNITY:
			OpenSceneByName(CommunityScene);
			break;

		case MAINMENU_OPTION_SETTINGS:
			OpenSceneByName(SettingsScene);
			break;

		case MAINMENU_OPTION_EXIT:
			OnMenu_ExitGame();
			break;
	}
}

/** Exit game option selected. */
function OnMenu_ExitGame()
{
	local array<string> MessageBoxOptions;

	MessageBoxReference = GetMessageBoxScene();

	if(MessageBoxReference != none)
	{
		MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.ExitGame>");
		MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.Cancel>");

		MessageBoxReference.SetPotentialOptions(MessageBoxOptions);
		MessageBoxReference.Display("<Strings:UTGameUI.MessageBox.ExitGame_Message>", "<Strings:UTGameUI.MessageBox.ExitGame_Title>", OnMenu_ExitGame_Confirm, 1);
	}

	MessageBoxReference = None;
}

/** Confirmation for the exit game dialog. */
function OnMenu_ExitGame_Confirm(UTUIScene_MessageBox MessageBox, int SelectedItem, int PlayerIndex)
{
	local UIScene SceneToOpenReference;

	if( SelectedItem == 0 )
	{
		if ( GetWorldInfo().IsDemoBuild() )
		{

			CloseScene(Self);
			SceneToOpenReference = UIScene(DynamicLoadObject(DemoSellScene, class'UIScene'));
			SceneClient.OpenScene(SceneToOpenReference);
		}
		else
		{
			ConsoleCommand("quit");
		}
	}
}

/** Calls the platform specific login function. */
function OnLogin()
{
	if(IsConsole(CONSOLE_Xbox360))
	{
		OnLogin360();
	}
	else if(!IsConsole())
	{
		OnLoginPC();
	}
}

/** Tries to logout the currently logged in player. */
function OnLogout(int PlayerIndex)
{
	local array<string> MessageBoxOptions;

	if(!IsConsole())
	{
		MessageBoxReference = GetMessageBoxScene();

		if(MessageBoxReference != none)
		{
			MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.LogOut>");
			MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.Cancel>");

			MessageBoxReference.SetPotentialOptions(MessageBoxOptions);
			MessageBoxReference.Display("<Strings:UTGameUI.MessageBox.Logout_Message>", "<Strings:UTGameUI.MessageBox.Logout_Title>", OnLogout_Confirm, 1);
		}

		MessageBoxReference = none;
	}
}

/** Confirmation for the exit game dialog. */
function OnLogout_Confirm(UTUIScene_MessageBox MessageBox, int SelectedItem, int PlayerIndex)
{
	local OnlinePlayerInterface PlayerInt;

	if(SelectedItem==0)
	{
		PlayerInt = GetPlayerInterface();

		// Set flag
		SetDataStoreStringValue("<Registry:bChangingLoginStatus>", "1");

		// Display a modal messagebox
		MessageBoxReference = GetMessageBoxScene();
		MessageBoxReference.DisplayModalBox("<Strings:UTGameUI.Generic.LoggingOut>","");

		LogoutPlayerIndex = PlayerIndex;
		PlayerInt.AddLogoutCompletedDelegate(GetPlayerOwner(PlayerIndex).ControllerId, OnLogoutCompleted);
		if (PlayerInt.Logout(GetPlayerOwner(PlayerIndex).ControllerId) == false)
		{
			OnLogoutCompleted(false);
		}
	}
}

/** Login handler for the 360. */
function OnLogin360()
{
	// Show player profiles blade
	ShowLoginUI(false);
}

/** Login handler for the PC. */
function OnLoginPC()
{
	local array<string> MessageBoxOptions;

	if(IsLoggedIn(INDEX_NONE))
	{
		MessageBoxReference = GetMessageBoxScene();

		if(MessageBoxReference != none)
		{
			MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.LogOut>");
			MessageBoxOptions.AddItem("<Strings:UTGameUI.ButtonCallouts.Cancel>");

			MessageBoxReference.SetPotentialOptions(MessageBoxOptions);
			MessageBoxReference.Display("<Strings:UTGameUI.MessageBox.MustLogoutToLogin_Message>", "<Strings:UTGameUI.MessageBox.MustLogoutToLogin_Title>", OnLoginPC_Logout_Confirm, 1);
		}

		MessageBoxReference = none;
	}
	else
	{
		OpenSceneByName(LoginScreenScene);
	}
}

/** Confirmation for the login game dialog. */
function OnLoginPC_Logout_Confirm(UTUIScene_MessageBox MessageBox, int SelectedItem, int PlayerIndex)
{
	if(SelectedItem==0)
	{
		OnLogout(PlayerIndex);
	}
}

/**
 * Delegate used in notifying the UI/game that the manual logout completed
 *
 * @param bWasSuccessful whether the async call completed properly or not
 */
function OnLogoutCompleted(bool bWasSuccessful)
{
	// Hide Message box
	MessageBoxReference.Close();
	MessageBoxReference.OnClosed = OnLogoutCompleted_LogoutMessageClosed;
	bLogoutWasSuccessful = bWasSuccessful;

	// Refresh the button bar.
	SetupButtonBar();
};

/** Called after the logging out message has disappeared. */
function OnLogoutCompleted_LogoutMessageClosed()
{
	local OnlinePlayerInterface PlayerInt;

	// Clear flag
	SetDataStoreStringValue("<Registry:bChangingLoginStatus>", "0");

	// Clear messagebox reference and delegates
	MessageBoxReference = None;
	PlayerInt = GetPlayerInterface();
	PlayerInt.ClearLogoutCompletedDelegate(GetPlayerOwner(LogoutPlayerIndex).ControllerId,OnLogoutCompleted);

	// Display a message box if logout failed.
	if(bLogoutWasSuccessful==false)
	{
		DisplayMessageBox("<Strings:UTGameUI.Errors.LogoutFailed_Message>","<Strings:UTGameUI.Errors.LogoutFailed_Title>");
	}
	else	// Otherwise show the login screen.
	{
		OpenSceneByName(LoginScreenScene);
	}
}

/**
 * Starts the Campaign.
 */
function StartCampaign(int PlayerIndex)
{
	OpenSceneByName(CampaignContinueScene);

}

/** Buttonbar Callbacks. */
function bool OnButtonBar_Login(UIScreenObject InButton, int InPlayerIndex)
{
	OnLogin();

	return true;
}

function bool OnButtonBar_Logout(UIScreenObject InButton, int InPlayerIndex)
{
	OnLogout(InPlayerIndex);

	return true;
}

/**
 * Provides a hook for unrealscript to respond to input using actual input key names (i.e. Left, Tab, etc.)
 *
 * Called when an input key event is received which this widget responds to and is in the correct state to process.  The
 * keys and states widgets receive input for is managed through the UI editor's key binding dialog (F8).
 *
 * This delegate is called BEFORE kismet is given a chance to process the input.
 *
 * @param	EventParms	information about the input event.
 *
 * @return	TRUE to indicate that this input key was processed; no further processing will occur on this input key event.
 */
function bool HandleInputKey( const out InputEventParameters EventParms )
{
	local bool bResult;

	bResult=false;

	if(EventParms.EventType==IE_Released)
	{
		if(EventParms.InputKeyName=='XboxTypeS_Y')
		{
			OnLogin();
			bResult=true;
		}
		else if(EventParms.InputKeyName=='XboxTypeS_X')
		{
			if(IsLoggedIn(INDEX_NONE))
			{
				OnLogout(EventParms.PlayerIndex);
			}

			bResult=true;
		}
	}

	if(bResult==false)
	{
		bResult = Super.HandleInputKey(EventParms);
	}

	return bResult;
}


defaultproperties
{
	bSupportBackButton=false
	InstantActionScene="UI_Scenes_ChrisBLayout.Scenes.InstantAction"
	MultiplayerScene="UI_Scenes_ChrisBLayout.Scenes.Multiplayer""
	SettingsScene="UI_Scenes_ChrisBLayout.Scenes.Settings"
	CommunityScene="UI_Scenes_ChrisBLayout.Scenes.Community"
	CampaignStartScene="UI_Scenes_Campaign.Scenes.CampOptions"
	CampaignContinueScene="UI_Scenes_Campaign.Scenes.CampNewOrContinue"
	LoginScreenScene="UI_Scenes_ChrisBLayout.Scenes.LoginScreen""
	DemoSellScene="UI_Scenes_FrontEnd.Scenes.DemoSell"

}
