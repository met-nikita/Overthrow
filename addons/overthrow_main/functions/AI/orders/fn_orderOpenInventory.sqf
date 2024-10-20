private _sorted = [];
private _unit = (groupSelectedUnits player) select 0;

{
    player groupSelectUnit [_x, false];
} forEach (groupSelectedUnits player);

if(!isNull objectParent _unit) then {
	_sorted = [vehicle _unit];
}else{
    private _objects = [];
    {
    	if!(_x isEqualTo _unit) then {_objects pushBack _x};
    }forEach(_unit nearEntities [["Car","ReammoBox_F","Air","Ship"],5]);
	if(count _objects isEqualTo 0) exitWith {
		_unit action ["Gear",objNull];
	};
	_sorted = [_objects,[],{_x distance _unit},"ASCEND"] call BIS_fnc_SortBy;
};

if((count _sorted) isEqualTo 0) exitWith {
    _unit action ["Gear",objNull];
};

private _target = _sorted select 0;

_unit globalChat format["Opening %1",(typeOf _target) call OT_fnc_vehicleGetName];

if(alive _unit) then {
	_unit action ["Gear",_target];
};
