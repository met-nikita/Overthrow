closeDialog 0;
OT_inputHandler = {
	_input = ctrlText 1400;
	if (_input isEqualType "" && count _input > 64) exitWith {hint "You can't take that much!"};
	_val = parseNumber _input;
	_cash = server getVariable ["money",0];
	if(_val > _cash) then {_val = _cash};
	if(_val > 0) then {
		[-_val] call OT_fnc_resistanceFunds;
        [_val] call OT_fnc_money;
	};
};

["How much to take from resistance?",1000] call OT_fnc_inputDialog;
