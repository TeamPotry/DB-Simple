#include <sourcemod>

#undef REQUIRE_PLUGIN
#include <db_simple>
#define REQUIRE_PLUGIN

#define PLUGIN_VERSION "20190729"

public Plugin myinfo=
{
	name="SourceMod DB Simple : TEST",
	author="Nopied◎",
	description="",
	version=PLUGIN_VERSION,
};

public void OnPluginStart()
{
	RegConsoleCmd("dbs_test", DBSTest_Cmd, "TEST");
}

static const char g_strTestColumn[][] = {
	"steam_id",
	"unique_id",
	"value",
	"value_2"
};

static const char g_strNoUniqueTestColumn[][] = {
	"steam_id",
	"value",
	"value_2"
};

public void DBS_OnLoadData(DBSData data)
{
	KeyValues tabledata = DBSData.CreateTableData("test");
	KeyValues tableTestData = DBSData.CreateTableData("test2", true);

	for(int loop = 0; loop < sizeof(g_strTestColumn); loop++)
	{
		DBSData.PushTableData(tabledata, g_strTestColumn[loop], DBSData_String);
	}

	for(int loop = 0; loop < sizeof(g_strNoUniqueTestColumn); loop++)
	{
		DBSData.PushTableData(tableTestData, g_strNoUniqueTestColumn[loop], DBSData_String);
	}

	data.Add("test", tabledata);
	data.Add("test", tableTestData);

	delete tabledata;
	delete tableTestData;
}

public Action DBSTest_Cmd(int client, int args)
{
    int value, noUniqueValue;
    char temp[8], export[4096];
    DBSData dbsMain = DBSData.Get();
    DBSPlayerData playerData = DBSPlayerData.GetClientData(client);

    playerData.GetData("test", "test", "123456", "value", temp, 8);

    value = StringToInt(temp) + 1;
    Format(temp, sizeof(temp), "%d", value);
    playerData.SetStringData("test", "test", "123456", "value", temp);

    playerData.GetData("test", "test2", "", "value", temp, 8);

    noUniqueValue = StringToInt(temp) + 1;
    Format(temp, sizeof(temp), "%d", noUniqueValue);
    playerData.SetStringData("test", "test2", "", "value", temp);

    PrintToChat(client, "test: %d, test1: %d", value, noUniqueValue);

    playerData.Rewind();
    playerData.ExportToString(export, 4096);
    LogMessage("%s", export);

    dbsMain.Rewind();
    dbsMain.ExportToString(export, 4096);
    LogMessage("%s", export);

	return Plugin_Continue;
}
