#pragma semicolon 1
#pragma newdecls required

#include <dhooks>

#define MULTIPLIER 4.0

DynamicDetour g_hDHook_CreateStringTable;

public Plugin myinfo =
{
	name 		= "string table expander, for TF2",
	author 		= "PŠΣ™ SHUFEN, sappho.io",
	description = "Port of https://forums.alliedmods.net/showthread.php?t=322106 to TF2, fixes several stringtables that servers can often run up against the limits of",
	version 	= "0.x",
	url 		= ""
};

public void OnPluginStart()
{
	GameData hGameData = new GameData("strtable_expander");
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
	// PrintToServer("DHookCallback_CreateStringTable(%08x, %x, %x)", pThis, hReturn, hParams);

	char tableName[MAX_NAME_LENGTH];
	hParams.GetObjectVarString(1, 0, ObjectValueType_String, tableName, sizeof(tableName));
	int maxentries = hParams.Get(2);

	// PrintToServer("[strtable_xpander] tableName=\"%s\" maxentries=%i udat_fixedsize=%i udat_networkbits=%i flags=%i", tableName, maxentries, hParams.Get(3), hParams.Get(4), hParams.Get(5));

	if
	(
		MULTIPLIER != 1.0
		&&
		(
			StrEqual(tableName, "ParticleEffectNames")
			||
			StrEqual(tableName, "DynamicModels")
		)
	)
	{
		int _maxentries = RoundToFloor(MULTIPLIER * maxentries);
		hParams.Set(2, _maxentries);

		PrintToServer("[strtable_xpander] overrode maxentries for tableName=\"%s\" to ->%d<-\n", tableName, _maxentries);
		return MRES_ChangedHandled;
	}

	// PrintToServer("[strtable_xpander] CreateStringTable: -> result=MRES_Ignored\n");
	return MRES_Ignored;
}
