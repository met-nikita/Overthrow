params ["_unit"];


_unit addItemToUniform "ACE_rangeCard";

_unit setVariable ["NOAI",true,false];
[
	{
		private _dir = random 360;
		private _pos = (_this getPos [1,_dir]);
		_this setPosATL [_pos select 0,_pos select 1,((getPosATL _this) select 2)+0.3];
		_this setDir _dir;
		_this setUnitPos "MIDDLE";
	},
	_unit,
	48
] call CBA_fnc_waitAndExecute;

_unit addEventHandler ["HandleDamage", {
	params ["_me","","","_src"];
	if(captive _src) then {
		if(!isNull objectParent _src || (_src call OT_fnc_unitSeenNATO)) then {
			_src setCaptive false;
		};
	};
}];
