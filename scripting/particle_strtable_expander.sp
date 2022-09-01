#pragma semicolon 1
#pragma newdecls required

#include <dhooks>

#define MULTIPLIER 4.0

DynamicDetour g_hDHook_CreateStringTable;

public Plugin myinfo =
{
	name = "Particle String Table Expander",
	author = "PŠΣ™ SHUFEN, sappho.io",
	description = "",
	version = "0.1tf2",
	url = "https://possession.jp"
};

public void OnPluginStart()
{
	GameData hGameData = new GameData("particle_strtable_expander");
	if (hGameData == null) {
		SetFailState("Cannot load ParticleStringTableExpander.games gamedata");
	}

	g_hDHook_CreateStringTable = DynamicDetour.FromConf(hGameData, "CNetworkStringTableContainer::CreateStringTable");

	delete hGameData;

	if (g_hDHook_CreateStringTable == null) {
		SetFailState("Cannot init g_hDHook_CreateStringTable detour");
	}

	g_hDHook_CreateStringTable.Enable(Hook_Pre, DHookCallback_CreateStringTable);
}

public MRESReturn DHookCallback_CreateStringTable(Address pThis, DHookReturn hReturn, DHookParam hParams)
{
	LogMessage("DHookCallback_CreateStringTable(%08x, %d, %d)", pThis, hReturn, hParams);

	char tableName[MAX_NAME_LENGTH];
	hParams.GetObjectVarString(1, 0, ObjectValueType_String, tableName, sizeof(tableName));
	int maxentries = hParams.Get(2);

	LogMessage("DHookCallback_CreateStringTable: tableName=\"%s\" maxentries=%d userdatafixedsize=%d userdatanetworkbits=%d flags=%d", tableName, maxentries, hParams.Get(3), hParams.Get(4), hParams.Get(5));

	if (MULTIPLIER != 1.0 && StrEqual(tableName, "ParticleEffectNames")) {
		int _maxentries = RoundToFloor(MULTIPLIER * maxentries);
		hParams.Set(2, _maxentries);

		LogMessage("DHookCallback_CreateStringTable: result=MRES_ChangedHandled > maxentries=%d", _maxentries);
		return MRES_ChangedHandled;
	}

	LogMessage("DHookCallback_CreateStringTable: result=MRES_Ignored");
	return MRES_Ignored;
}
