_precision = _this select 0;


////// DONT CHANGE ANYTHING BELOW
local_recording = [];
single_current_values = [];
all_current_values = [];
current_unit = [];
current_daytime = 0;


waitUntil {BLUFOR_TELEPORTED};

while{true} do
{

	if (MISSION_COMPLETED) exitWith {};

		allDeadAndAliveUnits = allUnits + allDeadMen + vehicles;
	{	_unit = _x;
		_veh = vehicle _unit;
		_pos = getpos _unit;
		_side = side (group _unit);
		_side_prefix = "";
		if (current_daytime == 0) then {
		current_daytime = daytime;
		};
		if (_side == west) then { _side_prefix = "b_";};
		if (_side == east) then { _side_prefix = "o_";};
		if (_side == independent) then { _side_prefix = "n_";};
		if (_side == civilian) then { _side_prefix = "c_";};
		_kindof = _side_prefix + "unknown";
		_dir = (getDir _unit);
		_hide = false;
		
		if (_unit isKindOf "WeaponHolderSimulated") exitWith {};

		
		// dont render another marker for the vehicle, if vehicle is not empty
		if (count (crew _unit) > 0 && ((crew _unit) select 0 != _unit)) then {
			_hide = true;
		};

		// dont render different stuff
		if (
			_unit isKindOf "ACE_wheel" ||
			_unit isKindOf "ACE_Track" 
			) then {
			_hide = true;
		};

		if(vehicle _unit == _unit) then 
		{
			_kindof =  "mil_triangle";
		};
		if((vehicle _unit isKindOf "Car") && (_side != civilian)) then 
		{
			_kindof =  _side_prefix + "motor_inf";
		};
		if((vehicle _unit isKindOf "Plane") && (_side != civilian)) then 
		{
			_kindof =  _side_prefix + "plane";
		};
		if((vehicle _unit isKindOf "Helicopter") && (_side != civilian)) then 
		{
			_kindof =  _side_prefix + "air";
		};
		if((vehicle _unit isKindOf "Tank") && (_side != civilian)) then 
		{
			_kindof =  _side_prefix + "armor";
		};
		if(vehicle _unit isKindOf "Ship") then 
		{	
			if (side _unit == civilian) then {
			 _kindof =  _side_prefix + "ship";
			} else {
			_kindof =  _side_prefix + "naval";
			};
		};

		if(vehicle _unit isKindOf "StaticMortar") then 
		{
			_kindof =  _side_prefix + "mortar";
		};

		if (_unit getVariable ["ACE_isUnconscious", false]) then {
			_kindof = "loc_Tree";
		};

		if (_unit isKindOf "TK_WarfareBUAVterminal_Base_EP1") then {
			_side = east;
			_kindof = "mil_start";
		};

		if (_unit isKindOf "US_WarfareBUAVterminal_Base_EP1") then {
			_side = west;
			_kindof = "mil_start";
		};

		if (!alive _unit) then {
			_kindof = "KIA";
		};

		if(_unit == funkwagen) then 
		{
			_isSending = call funkwagenIsSending;

			if (_isSending) then {
				_kindof =  "loc_Transmitter";
			} else {
				_kindof = "loc_BusStop";
			};
		};

		if(vehicle _unit == funkwagen) then 
		{
			_isSending = call funkwagenIsSending;

			if (_isSending) then {
				_kindof =  "loc_Transmitter";
			} else {
				_kindof = "loc_BusStop";
			};
		};



		// current values: position, side, kindof
		single_current_values = [_unit,_side,_pos,_dir,_kindof,_veh,_hide];
		//diag_log format ["%1",single_current_values];
		// prevent markers to render double on the same position (e.g. full team in vehicle)
		if (!(_veh in all_current_values)) then {
			
		all_current_values = all_current_values + [single_current_values];
		};
		
	} forEach allDeadAndAliveUnits;
	local_recording = local_recording + [[current_daytime,"",all_current_values]];
	all_current_values = [];

	
	sleep _precision;

	//reset all current values
	current_daytime = 0;
};