private ["_unit","_numslots","_weapon","_magazine","_base","_config"];
_unit = _this;

_unit setVariable ["mobboss",true,false];

private _firstname = selectRandom OT_firstNames_local;
private _lastname = selectRandom OT_lastNames_local;
private _fullname = [format["%1 %2",_firstname,_lastname],_firstname,_lastname];
[_unit,_fullname] remoteExecCall ["setName",0,_unit];

_unit addEventHandler ["HandleDamage", {
	_me = _this select 0;
	_src = _this select 3;
	if(captive _src) then {
		if(!isNull objectParent _src || (_src call OT_fnc_unitSeenCRIM)) then {
			_src setCaptive false;
		};
	};
}];

[_unit, OT_face_localBoss] remoteExecCall ["setFace", 0, _unit];
[_unit, (selectRandom OT_voices_local)] remoteExecCall ["setSpeaker", 0, _unit];
_unit forceAddUniform OT_clothes_mob;

removeAllItems _unit;
removeHeadgear _unit;
removeAllWeapons _unit;
removeVest _unit;
removeAllAssignedItems _unit;

_unit addWeaponGlobal "Laserdesignator_02_ghex_F";
_unit addGoggles "G_Bandanna_beast";
_unit addHeadgear "H_Booniehat_khk_hs";

_unit linkItem "ItemMap";
_unit linkItem "ItemCompass";
_unit addVest (selectRandom OT_allExpensiveVests);
if(OT_hasTFAR) then {
	_unit linkItem "tf_fadak";
}else{
	_unit linkItem "ItemRadio";
};
_hour = date select 3;
if(_hour < 8 || _hour > 15) then {
	_unit linkItem "O_NVGoggles_ghex_F";
};

_unit linkItem "ACE_Altimeter";
_unit linkItem "ACE_Cellphone";

_weapon = selectRandom (OT_CRIM_Weapons + OT_allCheapRifles);
_base = [_weapon] call BIS_fnc_baseWeapon;
_magazine = (getArray (configFile / "CfgWeapons" / _base / "magazines")) select 0;
_unit addMagazine _magazine;
_unit addMagazine _magazine;
_unit addMagazine _magazine;
_unit addMagazine _magazine;
_unit addMagazine _magazine;
_unit addMagazine _magazine;
_unit addMagazine _magazine;
_unit addWeaponGlobal _weapon;

_config = configFile >> "CfgWeapons" >> _weapon >> "WeaponSlotsInfo";
_numslots = count(_config);
for "_i" from 0 to (_numslots-1) do {
	if (isClass (_config select _i)) then {
		_slot = configName(_config select _i);
		_com = _config >> _slot >> "compatibleItems";
		_items = [];
		if (isClass (_com)) then {
			for "_t" from 0 to (count(_com)-1) do {
				_items pushBack (configName(_com select _t));
			};
		}else{
			_items = getArray(_com);
		};
		if(count _items > 0) then {
			_cls = selectRandom _items;
			_unit addPrimaryWeaponItem _cls;
		};
	};
};

_weapon = selectRandom OT_allHandguns;
_unit addWeaponGlobal _weapon;
_base = [_weapon] call BIS_fnc_baseWeapon;
_magazine = (getArray (configFile / "CfgWeapons" / _base / "magazines")) select 0;
if !(isNil "_magazine") then {
	_unit addItem _magazine;
};
