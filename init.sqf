// spawn teleports done?
OPFOR_TELEPORTED = false;
BLUFOR_TELEPORTED = false;

if (isServer) then {
	bluforMarkerDrawn = false;
	publicVariable "bluforMarkerDrawn";
};

// spawn distances from objective min/max
blufor_spawnDistanceMin = 1000;
blufor_spawnDistanceMax = 5000;

opfor_teleport = opfor_teamlead addAction["<t color=""#93E352"">" + "Spawnpunkt wählen",{[[[false], "mission_setup\teleport.sqf"],"BIS_fnc_execVM",true,true] spawn BIS_fnc_MP;  }, _Args, 1, false, true, "","_this == _target && !OPFOR_TELEPORTED"];
blufor_teleport = blufor_teamlead addAction["<t color=""#93E352"">" + "Spawnpunkt wählen",{[[[false], "mission_setup\teleport.sqf"],"BIS_fnc_execVM",true,true] spawn BIS_fnc_MP;  }, _Args, 1, false, true, "","_this == _target && !BLUFOR_TELEPORTED && OPFOR_TELEPORTED"];

call compile preprocessFileLineNumbers "plank\plank_init.sqf";				//Plank

enableSentences false;														//Autospotten

if (side player == east) then 												
{
[player, [0, 0, 1, 0, 1, 0, 0, 0, 1, 1]] call plank_deploy_fnc_init;
};

if (isServer) then { setDate [2035, 6, 24, (paramsArray select 0), 1]; };	//Zeit

[] execVM "objectives\detect_all_dead.sqf";