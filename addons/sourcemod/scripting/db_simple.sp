#include <sourcemod>
#include <db_simple>
#include <smjansson>
#include <SteamWorks>

#include "db_simple/global_var.sp"
#include "db_simple/transaction.sp"
#include "db_simple/native.sp"

#define PLUGIN_VERSION "20220710"

public Plugin myinfo=
{
	name="SourceMod DB Simple",
	author="Nopied◎",
	description="",
	version=PLUGIN_VERSION,
};

public APLRes AskPluginLoad2(Handle myself, bool late, char[] error, err_max)
{
	// db_simple/native.sp
	Native_Init();

	OnLoadData = CreateGlobalForward("DBS_OnLoadData", ET_Ignore, Param_Any); // LoadedDBData
	OnPlayerLoadData = CreateGlobalForward("DBS_OnLoadPlayerData", ET_Ignore, Param_Any, Param_Cell); // LoadedPlayerData, client

	return APLRes_Success;
}

public void OnPluginStart()
{
	// Nothing for now!
}

public void OnMapStart()
{
	Database db = null;

	if(LoadedDBData != null) {
		LoadedDBData.Rewind();
		if(LoadedDBData.GotoFirstSubKey())
		{
			do
			{
				if((db = view_as<Database>(LoadedDBData.GetNum("connection"))) != view_as<Database>(0))
					delete db;
			}
			while(LoadedDBData.GotoNextKey());
		}
		delete LoadedDBData;
	}

	LoadedDBData = DBSData.Create();
}

public void OnClientAuthorized(int client, const char[] auth)
{
	LoadedPlayerData[client] = DBSPlayerData.Load(client);
}

public void OnClientDisconnect(int client)
{
	if(!IsFakeClient(client) && LoadedPlayerData[client] != null)
		LoadedPlayerData[client].Update();

	delete LoadedPlayerData[client];
}
