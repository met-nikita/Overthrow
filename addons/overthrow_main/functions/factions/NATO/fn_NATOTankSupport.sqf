params ["_frompos","_attackpos","_strength","_delay"];
sleep _delay;

private _num = 1+floor(_strength / 200);

private _count = 0;

private _group = createGroup blufor;

while {_count < _num} do {
	private _vehtype = selectRandom OT_NATO_Vehicles_TankSupport;

	private _dir = (_frompos getDir _attackpos);
	private _pos = _frompos findEmptyPosition [10,100,_vehtype];
    if (count _pos == 0) then {_pos = _frompos findEmptyPosition [0,100,_vehtype]};

	_veh = createVehicle [_vehtype, _pos, [], 0,""];
	_veh setVariable ["garrison","HQ",false];

	clearWeaponCargoGlobal _veh;
	clearMagazineCargoGlobal _veh;
	clearItemCargoGlobal _veh;
	clearBackpackCargoGlobal _veh;

	_veh setDir (_dir);
	_group addVehicle _veh;
	createVehicleCrew _veh;
	{
		[_x] joinSilent _group;
		_x setVariable ["garrison","HQ",false];
		_x setVariable ["NOAI",true,false];
	}forEach(crew _veh);
	_count = _count + 1;
	sleep 0.3;

	{
        _x addCuratorEditableObjects [[_veh]];
    }forEach(allCurators);
};

_wp = _group addWaypoint [_attackpos,100];
_wp setWaypointType "SAD";
_wp setWaypointBehaviour "COMBAT";
_wp setWaypointTimeout [600,600,600];

_wp = _group addWaypoint [_frompos,100];
_wp setWaypointType "SCRIPTED";
_wp setWaypointStatements ["true","[vehicle this] call OT_fnc_cleanup"];
