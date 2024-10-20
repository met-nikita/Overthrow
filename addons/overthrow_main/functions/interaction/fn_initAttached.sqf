private _veh = _this select 0;
_am = [];
if(count _this > 1) then {_am = _this select 1};
private _cls = _veh getVariable ["OT_attachedClass",""];

if(_cls isEqualTo "") exitWith {};

private _item = [];
{
	if((_x select 4) == _cls && (typeOf _veh) == (_x select 1)) exitWith {_item = _x};
}forEach(OT_workshop);

_attachat = [0,0,0];
if(count _item > 0) then {
	_attachat = _item select 5;
};

_wpn = _cls createVehicle [0,0,0];
_wpn attachTo [_veh,_attachat select 0];
_wpn setDir (_attachat select 1);

if(count _am > 0) then {
    //set ammo
    {
        _wpn setAmmo [_x select 0,_x select 1];
    }forEach(_am);
};

_veh setVariable ["OT_attachedWeapon",_wpn,true];
_veh setVariable ["OT_Local",false,true];

_veh animate ["hideRearDoor",1];
_veh animate["hideSeatsRear",1];

[_wpn,"GetOut",{(_this select 2) moveInAny (attachedTo(_this select 0)); doGetOut (_this select 2)}] remoteExec ["addEventHandler", 0, true];

 _Dname = getText (configFile >> "cfgVehicles" >> (typeOf _wpn) >> "displayName");
[_veh,format["Get in %1 as Gunner",_Dname],"<img size='2' image='\a3\ui_f\data\IGUI\Cfg\Actions\getingunner_ca.paa'/>"] remoteExec ["OT_UpdateGetInState", 0, true];
_ls = [ (_this select 0),"","","","speed _target <= 1 && speed _target >= -1 && _target distance _this < 5  && isNull objectParent _this && ( !((_target getVariable 'OT_Attached') isEqualType false) || !((_target getVariable 'OT_Local') isEqualType false))","true",{},{},{},{},[],13,nil,false,false] call BIS_fnc_holdActionAdd;
_vls = (_this select 0) addAction ["", {[(_this select 0),(_this select 1)] spawn OT_fnc_mountAttached;},[],5.5,true,true,"","typeNAME (_target getVariable 'OT_Attached') != 'BOOL' && _target distance _this < 5"];
(_this select 0) setVariable ["OT_Act",_ls,false];
(_this select 0) setVariable ["OT_Act_GetIn",_vls,false];
(_this select 0) setVariable["OT_Attached",false,true];
(_this select 0) setVariable["OT_Local",false,true];
