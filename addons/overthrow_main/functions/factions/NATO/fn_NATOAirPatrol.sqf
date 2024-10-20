//Scramble a helicopter to take out a target
params ["_frombase","_waypoints",["_delay",0]];

if((count _waypoints) < 2) exitWith {};

private _abandoned = server getVariable ["NATOabandoned",[]];
if !(_frombase in _abandoned) then {
    if(_delay > 0) then {sleep _delay};
    diag_log format["Overthrow: NATO Sending air patrol from %1",_frombase];

    private _vehtype = selectRandom OT_NATO_Vehicles_AirSupport_Small;
    if((call OT_fnc_getControlledPopulation) > 1500) then {_vehtype = selectRandom OT_NATO_Vehicles_AirSupport};

    private _frompos = server getVariable _frombase;
    private _pos = _frompos findEmptyPosition [15,100,_vehtype];
    if (count _pos == 0) then {_pos = _frompos findEmptyPosition [8,100,_vehtype]};

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

    {
        _wp = _group addWaypoint [_x,50];
        _wp setWaypointType "SAD";
        _wp setWaypointBehaviour "SAFE";
        _wp setWaypointSpeed "FULL";
        _wp setWaypointTimeout [300,300,300];
    }forEach(_waypoints);

    _timeout = time + ((count _waypoints) * 300);

    waitUntil {sleep 10;!isNil "_veh" && alive _veh && time > _timeout};

    while {(count (waypoints _group)) > 0} do {
        deleteWaypoint ((waypoints _group) select 0);
    };

    sleep 1;

    if(isNil "_veh" || !alive _veh) exitWith {};

    _wp = _group addWaypoint [_frompos,50];
    _wp setWaypointType "MOVE";
    _wp setWaypointBehaviour "SAFE";
    _wp setWaypointSpeed "FULL";

    waitUntil{sleep 10;(alive _veh && (_veh distance _frompos) < 150) || !alive _veh};

    if(alive _veh) then {
        while {(count (waypoints _group)) > 0} do {
            deleteWaypoint ((waypoints _group) select 0);
        };
        _veh land "LAND";
        // Sometimes helicopters land just briefly and take off again, so checking this every second
        waitUntil{sleep 1;(getPos _veh)#2 < 2};
    };
    _veh call OT_fnc_cleanup;
    _group call OT_fnc_cleanup;
};
