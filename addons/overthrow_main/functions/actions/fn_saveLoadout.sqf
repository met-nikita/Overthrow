OT_inputHandler = {
	_name = ctrlText 1400;
	if (_name isEqualType "" && count _name > 64) exitWith {hint "Loadout name is too long!"};
	if(_name != "") then {
		profileNamespace setVariable [format["OT_loadout_%1",_name],getUnitLoadout player];
		_loadouts = profileNamespace getVariable ["OT_loadouts",[]];
		_idx = _loadouts find _name;
		if(_idx isEqualTo -1) then {
			_loadouts pushBack _name;
		};
		profileNamespace setVariable ["OT_loadouts",_loadouts];
	};	
};

["Name this loadout",""] call OT_fnc_inputDialog;