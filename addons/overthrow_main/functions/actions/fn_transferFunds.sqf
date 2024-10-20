closeDialog 0;
private _idx = lbCurSel 1500;
inputData = lbData [1500,_idx];
OT_inputHandler = {
	_input = ctrlText 1400;
	if (_input isEqualType "" && count _input > 64) exitWith {hint "You can't send that much!"};
	_val = parseNumber _input;
	_cash = server getVariable ["money",0];
	if(_val > _cash) then {_val = _cash};
	if(_val > 0) then {
		[-_val] call OT_fnc_resistanceFunds;
		_player = objNull;
		private _uid = inputData;
		{
		    if(getPlayerUID _x isEqualTo _uid) exitWith {_player = _x};
		}forEach(allPlayers);
		if !(isNull _player) then {
			[_val] remoteExec ["OT_fnc_money",_player,false];
		}else{
			private _money = [_uid,"money"] call OT_fnc_getOfflinePlayerAttribute;
			[_uid,"money",_money+_val] call OT_fnc_setOfflinePlayerAttribute;
		};
		format["Transferred $%1 resistance funds to %2",[_val, 1, 0, true] call CBA_fnc_formatNumber,players_NS getVariable [format["name%1",_uid],"player"]] call OT_fnc_notifyMinor;
	};
};

["How much to send to this player?",1000] call OT_fnc_inputDialog;
