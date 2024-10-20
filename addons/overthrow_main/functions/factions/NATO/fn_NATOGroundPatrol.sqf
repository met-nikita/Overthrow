//Send a patrol vehicle to a town
params ["_frombase","_topos",["_delay",0]];

private _abandoned = server getVariable ["NATOabandoned",[]];
if !(_frombase in _abandoned) then {
    if(_delay > 0) then {sleep _delay};
    diag_log format["Overthrow: NATO Sending patrol from %1",_frombase];

    private _vehtype = selectRandom OT_NATO_Vehicles_Convoy;
    if((call OT_fnc_getControlledPopulation) > 2000) then {_vehtype = selectRandom OT_NATO_Vehicles_TankSupport};

    private _frompos = server getVariable _frombase;
    private _pos = _frompos findEmptyPosition [10,100,_vehtype];
    if (count _pos == 0) then {_pos = _frompos findEmptyPosition [0,100,_vehtype]};

    private _group = createGroup blufor;
    private _veh = _vehtype createVehicle _pos;
    _veh setVariable ["garrison","HQ",false];

    {
        _x addCuratorEditableObjects [[_veh]];
    }forEach(allCurators);

    clearWeaponCargoGlobal _veh;
    clearMagazineCargoGlobal _veh;
    clearItemCargoGlobal _veh;
    clearBackpackCargoGlobal _veh;

    _group addVehicle _veh;
    createVehicleCrew _veh;
    {
    	[_x] joinSilent _group;
    	_x setVariable ["garrison","HQ",false];
    	_x setVariable ["NOAI",true,false];
    }forEach(crew _veh);
    sleep 1;
    private _attackpos = _topos getPos [random 200, random 360];

    _wp = _group addWaypoint [_attackpos,50];
    _wp setWaypointType "SAD";
    _wp setWaypointBehaviour "SAFE";
    _wp setWaypointSpeed "FULL";
    _wp setWaypointTimeout [1200,1200,1200];

    _timeout = time + 1200;

    waitUntil {sleep 10;alive _veh && time > _timeout};

    while {(count (waypoints _group)) > 0} do {
        deleteWaypoint ((waypoints _group) select 0);
    };

    sleep 1;

    _wp = _group addWaypoint [_frompos,50];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "SAFE";
    _wp setWaypointSpeed "FULL";

    waitUntil{sleep 10;(alive _veh && (_veh distance _frompos) < 150) || !alive _veh};

    if(alive _veh) then {
        while {(count (waypoints _group)) > 0} do {
            deleteWaypoint ((waypoints _group) select 0);
        };
        waitUntil{sleep 10;(speed _veh) isEqualTo 0};
    };
    _veh call OT_fnc_cleanup;
    _group call OT_fnc_cleanup;
};
