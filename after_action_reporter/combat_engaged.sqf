_unit = _this select 0;
_shotguy = _this select 1;
_side = side _unit;
if(_side != side _shotguy) then
{
	_random = round(random 100000);
	_marker = createMarker [format["combat_%1_%2",_random,_side],getpos _shotguy];
	_marker setMarkerAlpha 0;
	AUSMD_markers set [count AUSMD_markers,_marker];
	if(_side == west) then
	{
		_marker setMarkerColor "ColorBlue";
	};
	if(_side == east) then
	{
		_marker setMarkerColor "ColorRed";
	};
	if(_side == resistance) then
	{
		_marker setMarkerColor "ColorGreen";
	};
	_marker setMarkerSize [0.5,0.5];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "KIA";
}
else
{
	//friendly fire
	_random = round(random 100000);
	_marker = createMarker [format["FF_%1_%2",_random,_side],getpos _unit];
	_marker setMarkerAlpha 0;
	_marker setMarkerSize [0.5,0.5];
	AUSMD_markers set [count AUSMD_markers,_marker];
	_marker setMarkerShape "ICON";
	_marker setMarkerType "KIA";
	_marker setMarkerColor "ColorOrange";
};


