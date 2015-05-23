#include "\z\ace\addons\main\script_component.hpp"
#include "\z\ace\addons\main\script_macros.hpp"

TIME_OF_DAY = paramsArray select 0;
WEATHER_SETTING = paramsArray select 1;
MBT_VS_AT = (paramsArray select 2) == 1;
BLUFORCE = paramsArray select 3;
OPFORCE = paramsArray select 4;
MINIMAL_BLUFOR_SPAWN_DISTANCE = paramsArray select 5;
MAXIMAL_BLUFOR_SPAWN_DISTANCE = paramsArray select 6;
TIME_ACCELERATION = paramsArray select 7;
IS_VANILLA = (paramsArray select 8) == 1;
AR3PLAY_ENABLE_REPLAY = (paramsArray select 9) == 1;
AR3PLAY_IS_STREAMABLE = (paramsArray select 10) == 1;

if (isClass(configFile >> (_this select 0) >> task_force_radio)) then {
	TFAR_ENABLED = true;
	} else {
	TFAR_ENABLED = false;
};

if (OPFOR_TELEPORTED) then {
	[player] execVM "onPlayerRespawn.sqf";
	if (!IS_VANILLA) then {
	[localize "str_GRAD_jip"] call EFUNC(common,displayTextStructured);
	} else {
	hintSilent "JIP leads to instant spectator";
	};
};

[] execVM "CSSA3\CSSA3_init.sqf";


// global options
did_replay = false;
loadoutInitFinished = false;

// spawn teleports done?
OPFOR_TELEPORTED = false;
BLUFOR_TELEPORTED = false;
WINCONDITIONOPFOR = false;
WINCONDITIONBLUFOR = false;
firstspawn = false;


EDITOR_MODE = false; // check if test is in editor/singleplayer
if (!isMultiplayer) then {
	EDITOR_MODE = true;
	{_x disableAI "MOVE"} forEach allUnits;
};

if (isServer) then {
	setTimeMultiplier TIME_ACCELERATION;

	BLUFOR_CAPTURED = false;
	publicVariable "BLUFOR_CAPTURED";
	MISSION_COMPLETED = false;
	publicVariable "MISSION_COMPLETED";
	bluforMarkerDrawn = false;
	publicVariable "bluforMarkerDrawn";
	publicVariable "MBT_VS_AT";
	BLUFOR_SURRENDERED = false;
	publicVariable "BLUFOR_SURRENDERED";
	END_MISSION_TRIGGERED = false;
	publicVariable "END_MISSION_TRIGGERED";
	SPECTATOR_LIST = [];
	publicVariable "SPECTATOR_LIST";
};


// respawn helper object, will be moved to objective location in teleport.sqf
opfor_teleport = opfor_teamlead addAction["<t color=""#93E352"">" + localize "str_GRAD_choose_spawn_location",{[[[false], "mission_setup\teleport.sqf"],"BIS_fnc_execVM",true,true] spawn BIS_fnc_MP;  }, _Args, 1, false, true, "","_this == _target && !OPFOR_TELEPORTED"];
blufor_teleport = blufor_teamlead addAction["<t color=""#93E352"">" + localize "str_GRAD_choose_spawn_location",{[[[false], "mission_setup\teleport.sqf"],"BIS_fnc_execVM",true,true] spawn BIS_fnc_MP;  }, _Args, 1, false, true, "","_this == _target && !BLUFOR_TELEPORTED && OPFOR_TELEPORTED"];

call compile preprocessFileLineNumbers "plank\plank_init.sqf";				//Plank
cameraOldPimped = compile preprocessFile "spectator\cameraOld_rip.sqf";
cameraNewPimped = compile preprocessFile "spectator\camera_rip.sqf";
If(isNil "spawn_help_fnc_compiled")then{call compile preprocessFileLineNumbers "helpers\findPos.sqf"};

enableSentences false;														//Autospotten

//abfangen ob slot belegt und dann ausführen der jeweiligen scripte
if (!isNil "opfor_teamlead") then {
	if (player == opfor_teamlead) then
	{
		[opfor_teamlead] execVM "mission_setup\callPlank.sqf";
	};
};


if (!isNil "opfor_engi") then {
	if (player == opfor_engi) then
	{
		[opfor_engi] execVM "mission_setup\callPlank.sqf";
	};
};

if (isServer) then { setDate [2035, 6, 24, TIME_OF_DAY, 1]; };	//Zeit




if ((isServer) || (isDedicated)) then {
	if (isClass (configFile >> "CfgPatches" >> "task_force_radio")) then
		{
		[] execVM "tfarsettings.sqf";
	};
	[] execVM "objectives\detect_all_dead.sqf";


	respawn_helper = "Land_MetalBarrel_F" createVehicle [(getPos sector_trigger select 0),(getPos sector_trigger select 1),0];
	
	[respawn_helper, true, [0,0,0], 180] call EFUNC(dragging,setDraggable);
	
	if (!IS_VANILLA) then {
	
	};

	[] spawn {
		while {true} do {
			if ((OPFOR_TELEPORTED) && (BLUFOR_TELEPORTED)) then {


					_pos =  [(getPos respawn_helper select 0), (getPos respawn_helper select 1), 0];
					sector_trigger setPos _pos;
					sector_module setPos _pos;
					//["sector_moduleWEST",_pos] call BIS_fnc_taskSetDestination;

					sleep 1;

			};
		};
	};
};
// call this on server too - because of whiteboard/truck
[] execVM "mission_setup\adjustInitialSpawnPosition.sqf";
// loadout call - giving each unit the appropriate sqf file

if !(isDedicated) then {
	[] execVM "mission_setup\helpBriefing.sqf";
	

	switchMoveEverywhere = compileFinal "_this select 0 switchMove (_this select 1);";
	["Preload"] call BIS_fnc_arsenal;


	if (!IS_VANILLA) then {		
		
			[player] execVM "loadouts\_client.sqf";
	
	} else {
		_nul1 = ["AmmoboxInit",[arsenal_opfor,true]] spawn BIS_fnc_arsenal;
		_nul2 = ["AmmoboxInit",[arsenal_blufor,true]] spawn BIS_fnc_arsenal;
	};

	// Intro Gruppe Adler

	titleCut ["", "BLACK FADED", 999];
	[] Spawn {

	titleText ["","PLAIN"];
	titleFadeOut 1;
	sleep 2;

	titleCut ["", "BLACK IN", 1];

	waitUntil {time > 3};
		["<img size= '6' shadow='false' image='pic\gruppe-adler.paa'/><br/><t size='.9' color='#FFFFFF'>OnTheFly</t>",0,0,2,2] spawn BIS_fnc_dynamicText;
	};
};


[WEATHER_SETTING] execVM "ga_weather\ga_start_weather.sqf";

if (isServer) then {
	waitUntil {OPFOR_TELEPORTED && BLUFOR_TELEPORTED};

	[] execVM "after_action_reporter_pimped\movement_vanillamarker.sqf";
};
