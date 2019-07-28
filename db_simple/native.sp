enum
{
	Load_ClientIndex = 0,
	Load_DBConfigName,
	Load_TableName,

	Load_Max
};

methodmap DBSPlayerdata_Preparing < ArrayList {
	public static DBSPlayerdata_Preparing Preparing(const int client, const char[] dbConfName, const char[] tablename)
	{
		DBSPlayerdata_Preparing array = view_as<DBSPlayerdata_Preparing>(new ArrayList(128, Load_Max));

		array.Set(Load_ClientIndex, client);
		array.SetString(Load_DBConfigName, dbConfName);
		array.SetString(Load_TableName, tablename);

		return array;
	}

	property int ClientIndex {
        public get()
        {
            return this.Get(Load_ClientIndex);
        }

        public set(int client)
        {
            this.Set(Load_ClientIndex, client);
        }
    }

    public void GetDBConfigName(char[] dbConfName, int buffer)
    {
    	this.GetString(Load_DBConfigName, dbConfName, buffer);
    }

    public void SetDBConfigName(const char[] dbConfName)
    {
    	this.SetString(Load_DBConfigName, dbConfName);
    }

    public void GetTableName(char[] tablename, int buffer)
    {
    	this.GetString(Load_TableName, tablename, buffer);
    }

    public void SetTableName(const char[] tablename)
    {
    	this.SetString(Load_TableName, tablename);
    }
}

void Native_Init()
{
    CreateNative("DBSData.Create", Native_DBSData_Create);
    CreateNative("DBSData.Get", Native_DBSData_Get);
    CreateNative("DBSData.CreateTableData", Native_DBSData_CreateTableData);
    CreateNative("DBSData.PushTableData", Native_DBSData_PushTableData);
    // CreateNative("DBSData.PushTableIndexSet", Native_DBSData_PushTableIndexSet);
    CreateNative("DBSData.GetTableDataType", Native_DBSData_GetTableDataType);
    CreateNative("DBSData.Add", Native_DBSData_Add);

    CreateNative("DBSPlayerData.Load", Native_DBSPlayerData_Load);
    CreateNative("DBSPlayerData.GetClientData", Native_DBSPlayerData_GetClientData);
    // CreateNative("DBSPlayerData.GetCurrentIndexSet", Native_DBSPlayerData_GetCurrentIndexSet);
    // CreateNative("DBSPlayerData.SetCurrentIndexSet", Native_DBSPlayerData_SetCurrentIndexSet);
    CreateNative("DBSPlayerData.Update", Native_DBSPlayerData_Update);
    CreateNative("DBSPlayerData.GetData", Native_DBSPlayerData_GetData);
    CreateNative("DBSPlayerData.SetData", Native_DBSPlayerData_SetData);
    CreateNative("DBSPlayerData.SetStringData", Native_DBSPlayerData_SetData);
}

public int Native_DBSData_Create(Handle plugin, int numParams)
{
	DBSData data = view_as<DBSData>(new KeyValues("DB_Data"));

	Call_StartForward(OnLoadData);
	Call_PushCell(data);
	Call_Finish();

	return view_as<int>(data);
}

public int Native_DBSData_Get(Handle plugin, int numParams)
{
	return view_as<int>(LoadedDBData);
}

public int Native_DBSData_CreateTableData(Handle plugin, int numParams)
{
	char tableName[128];
	GetNativeString(1, tableName, sizeof(tableName));
	KeyValues kv = new KeyValues(tableName);

	return view_as<int>(kv);
}

public int Native_DBSData_PushTableData(Handle plugin, int numParams)
{
	KeyValues tableData = GetNativeCell(1);

	char column[128];
	GetNativeString(2, column, sizeof(column));

	tableData.Rewind();
	tableData.JumpToKey("columns", true);
	tableData.SetNum(column, GetNativeCell(3));
}

/*
public int Native_DBSData_PushTableIndexSet(Handle plugin, int numParams)
{
	KeyValues tableData = GetNativeCell(1);

	char indexSet[128];
	GetNativeString(2, indexSet, sizeof(indexSet));

	int indexType = GetNativeCell(3);

	tableData.Rewind();
	tableData.JumpToKey("index", true);
	tableData.JumpToKey(indexSet, true);

	for(int loop = 4; loop < numParams; loop++)
	{
		GetNativeString(loop, indexSet, sizeof(indexSet));
		tableData.SetNum(indexSet, indexType);
	}
}
*/

public int Native_DBSData_GetTableDataType(Handle plugin, int numParams)
{
	DBSData data = GetNativeCell(1);
	char dbConfName[128], tableName[128], column[128];

	GetNativeString(2, dbConfName, sizeof(dbConfName));
	GetNativeString(3, tableName, sizeof(tableName));
	GetNativeString(4, column, sizeof(column));

	data.Rewind();
	if(!data.JumpToKey(dbConfName) || !data.JumpToKey("table_data") || !data.JumpToKey(tableName) || !data.JumpToKey("columns"))
		ThrowError("Must add table data before getting this. (%s > %s)", dbConfName, tableName);

	return data.GetNum(column, view_as<int>(KvData_None)); // KvData_None
}

public int Native_DBSData_Add(Handle plugin, int numParams)
{
	DBSData data = GetNativeCell(1);

	char dbConfName[128], error[256];
	GetNativeString(2, dbConfName, sizeof(dbConfName));

	Database db = SQL_Connect(dbConfName, false, error, sizeof(error));
	if(db == null) {
		ThrowError("[DBS] Error: %s", error);
	}

	KeyValues kv = GetNativeCell(3);

	data.Rewind();
	data.JumpToKey(dbConfName, true);
	data.SetNum("connection", view_as<int>(db));

	data.JumpToKey("table_data", true);

	kv.Rewind();
	kv.GetSectionName(dbConfName, sizeof(dbConfName));

	data.JumpToKey(dbConfName, true);
	data.Import(kv);
}

public int Native_DBSPlayerData_Load(Handle plugin, int numParams)
{
	int client = GetNativeCell(1);
	Database db;
	char queryStr[512], dbConfName[128], tableName[128], column[128], authId[25];
	GetClientAuthId(client, AuthId_SteamID64, authId, 25);
	DBSPlayerData playerData = view_as<DBSPlayerData>(new KeyValues("DB_PlayerData", "auth_id", authId));

	Call_StartForward(OnPlayerLoadData);
	Call_PushCell(LoadedPlayerData[client]);
	Call_PushCell(client);
	Call_Finish();

	LoadedDBData.Rewind();
	if(LoadedDBData.GotoFirstSubKey())
	{
		do
		{
			if((db = view_as<Database>(LoadedDBData.GetNum("connection"))) != view_as<Database>(0))
			{
				LoadedDBData.GetSectionName(dbConfName, sizeof(dbConfName));
				LoadedDBData.JumpToKey("table_data", true);
				if(LoadedDBData.GotoFirstSubKey())
				{
					do
					{
						LoadedDBData.GetSectionName(tableName, sizeof(tableName));

						LoadedDBData.JumpToKey("columns", true);

						LoadedDBData.GotoFirstSubKey(false);
						LoadedDBData.GetSectionName(column, sizeof(column));
						LoadedDBData.GoBack();
						LoadedDBData.GoBack();

						Format(queryStr, sizeof(queryStr), "SELECT * FROM `%s` WHERE `%s` = '%s'", tableName, column, authId);
						LogError("%s", queryStr);
						db.Query(DBSPlayerData_Load, queryStr, DBSPlayerdata_Preparing.Preparing(client, dbConfName, tableName));
					}
					while(LoadedDBData.GotoNextKey());
					LoadedDBData.GoBack();
				}
				LoadedDBData.GoBack();
			}
		}
		while(LoadedDBData.GotoNextKey());
	}

	return view_as<int>(playerData);
}

enum
{
	PlayerData_STEAMID = 0,
	PlayerData_Unique,
	PlayerData_Other
};

public void DBSPlayerData_Load(Database db, DBResultSet results, const char[] error, DBSPlayerdata_Preparing preparingData)
{
	char temp[256], dbConfName[128], tableName[128], column[128], unique[128];
	int client = preparingData.ClientIndex, firstPosId, count = 0;
	preparingData.GetDBConfigName(dbConfName, sizeof(dbConfName));
	preparingData.GetTableName(tableName, sizeof(tableName));
	delete preparingData;

	if(results == null)
		ThrowError("%s", error);

	LoadedDBData.GetSectionSymbol(firstPosId);
	LoadedDBData.Rewind();

	if(results.RowCount > 0) {
		for(int loop = 0; loop < results.RowCount; loop++)
		{
			if(!results.FetchRow()) {
				if(results.MoreRows) {
					loop--;
					continue;
				}
				break;
			}

			count = PlayerData_STEAMID;
			results.FetchString(PlayerData_Unique, unique, sizeof(unique));

			LoadedDBData.JumpToKey(dbConfName);
			LoadedDBData.JumpToKey("table_data", true);
			LoadedDBData.JumpToKey(tableName);
			LoadedDBData.JumpToKey("columns", true);

			LoadedPlayerData[client].Rewind();
			LoadedPlayerData[client].JumpToKey(dbConfName, true);
			LoadedPlayerData[client].JumpToKey(tableName, true);
			LoadedPlayerData[client].JumpToKey(unique, true);

			if(LoadedDBData.GotoFirstSubKey(false))
			{
				do
				{
					LoadedDBData.GetSectionName(column, sizeof(column));
					// LoadedPlayerData[client].JumpToKey(column, true);

					LogError("%s", column);

					results.FetchString(count++, temp, 256);
					LoadedPlayerData[client].SetString(column, temp);
				}
				while(LoadedDBData.GotoNextKey(false));
			}
		}
	}

	LoadedDBData.JumpToKeySymbol(firstPosId);
}

public int Native_DBSPlayerData_GetClientData(Handle plugin, int numParams)
{
    return view_as<int>(LoadedPlayerData[GetNativeCell(1)]);
}
/*
public int Native_DBSPlayerData_GetCurrentIndexSet(Handle plugin, int numParams)
{
	DBSPlayerData playerData = view_as<DBSPlayerData>(GetNativeCell(1));
	char dbConfName[128], tableName[128], result[256];

	GetNativeString(2, dbConfName, sizeof(dbConfName));
	GetNativeString(3, tableName, sizeof(tableName));

	playerData.Rewind();
	if(!playerData.JumpToKey(dbConfName) || !playerData.JumpToKey(tableName))
		ThrowError("Must add index set before getting this. (%s > %s)", dbConfName, tableName);

	playerData.GetString("current indexset", result, sizeof(result));
	SetNativeString(4, result, GetNativeCell(5));
}

public int Native_DBSPlayerData_SetCurrentIndexSet(Handle plugin, int numParams)
{
	DBSPlayerData playerData = view_as<DBSPlayerData>(GetNativeCell(1));
	char dbConfName[128], tableName[128], indexSet[128];

	GetNativeString(2, dbConfName, sizeof(dbConfName));
	GetNativeString(3, tableName, sizeof(tableName));
	GetNativeString(4, indexSet, sizeof(indexSet));

	playerData.Rewind();
	playerData.JumpToKey(dbConfName, true);
	playerData.JumpToKey(tableName, true);

	playerData.SetString("current indexset", indexSet);
}
*/

public int Native_DBSPlayerData_Update(Handle plugin, int numParams)
{
	// TODO: Transaction.
	DBSPlayerData playerData = GetNativeCell(1);
	Database db;

	int count;
	char queryStr[512], dbConfName[128], tableName[128], unique[128], column[128], authId[25];
	char authIdColumn[128], uniqueColumn[128], data[128];

	LoadedDBData.Rewind();
	playerData.Rewind();

	playerData.GetString("auth_id", authId, 25);
	if(!playerData.GotoFirstSubKey())
		return 0;

	do
	{
		playerData.GetSectionName(dbConfName, sizeof(dbConfName));
		if(!LoadedDBData.JumpToKey(dbConfName)) {
			LogError("There's no ''%s''!", dbConfName);
			continue;
		}

		db = view_as<Database>(LoadedDBData.GetNum("connection"));

		LoadedDBData.JumpToKey("table_data", true);
		playerData.GotoFirstSubKey();
		do
		{
			Transaction transaction = new Transaction();
			playerData.GetSectionName(tableName, sizeof(tableName));

			LoadedDBData.JumpToKey(tableName, true);
			LoadedDBData.JumpToKey("columns", true);

			LoadedDBData.GotoFirstSubKey(false);
			playerData.GotoFirstSubKey();
			do
			{
				count = 0;
				playerData.GetSectionName(unique, sizeof(unique));

				do
				{
					switch(count)
					{
						case PlayerData_STEAMID:
						{
							LoadedDBData.GetSectionName(authIdColumn, sizeof(authIdColumn));
						}
						case PlayerData_Unique:
						{
							LoadedDBData.GetSectionName(uniqueColumn, sizeof(uniqueColumn));
						}
						default:
						{
							LoadedDBData.GetSectionName(column, sizeof(column));
							playerData.GetString(column, data, sizeof(data), "");

							if(strlen(data) == 0) continue;

							Format(queryStr, sizeof(queryStr),
								"INSERT INTO `%s` (`%s`, `%s`, `%s`) VALUES ('%s', '%s', '%s') ON DUPLICATE KEY UPDATE `%s` = '%s',  `%s` = '%s', `%s` = '%s'",
									tableName, authIdColumn, uniqueColumn, column,
									authId, unique, data,
									authIdColumn, authId, uniqueColumn, unique, column, data);

							LogError("%s", queryStr);
							transaction.AddQuery(queryStr);
						}
					}

					count++;
				}
				while(LoadedDBData.GotoNextKey(false));
			}
			while(playerData.GotoNextKey());

			playerData.GoBack();
			LoadedDBData.GoBack();
			LoadedDBData.GoBack();
			LoadedDBData.GoBack();
			db.Execute(transaction, _, OnTransactionError);
		}
		while(playerData.GotoNextKey());

		playerData.GoBack();
	}
	while(playerData.GotoNextKey());

	return 0;
}

public void OnTransactionError(Database db, any data, int numQueries, const char[] error, int failIndex, any[] queryData)
{
	LogError("Something is Error while saving data. \n%s", error);
}


public int Native_DBSPlayerData_GetData(Handle plugin, int numParams)
{
	DBSPlayerData playerData = view_as<DBSPlayerData>(GetNativeCell(1));
	char dbConfName[128], tableName[128], column[128], result[256], unique[128];

	GetNativeString(2, dbConfName, sizeof(dbConfName));
	GetNativeString(3, tableName, sizeof(tableName));
	GetNativeString(4, unique, sizeof(unique));
	GetNativeString(5, column, sizeof(column));

	playerData.Rewind();
	playerData.JumpToKey(dbConfName, true);
	playerData.JumpToKey(tableName, true);
	playerData.JumpToKey(unique, true);

	KvDataTypes dataType = LoadedDBData.GetTableDataType(dbConfName, tableName, column);
	switch(dataType)
	{
		case KvData_Int:
		{
			return playerData.GetNum(column, 0);
		}
		case KvData_Float:
		{
			return view_as<int>(playerData.GetFloat(column, 0.0));
		}
		case KvData_String:
		{
			playerData.GetString(column, result, sizeof(result), "");
			SetNativeString(6, result, GetNativeCell(7));
		}
		default:
		{
			ThrowError("dataType is invalid! This should set value that we supported. (%s > %s > column = ''%s'')", dbConfName, tableName, column);
		}
	}

	return true; // 1
}

public int Native_DBSPlayerData_SetData(Handle plugin, int numParams)
{
	DBSPlayerData playerData = view_as<DBSPlayerData>(GetNativeCell(1));
	char dbConfName[128], tableName[128], column[128], unique[128];

	GetNativeString(2, dbConfName, sizeof(dbConfName));
	GetNativeString(3, tableName, sizeof(tableName));
	GetNativeString(4, unique, sizeof(unique));
	GetNativeString(5, column, sizeof(column));

	playerData.Rewind();
	playerData.JumpToKey(dbConfName, true);
	playerData.JumpToKey(tableName, true);
	playerData.JumpToKey(unique, true);

	KvDataTypes dataType = LoadedDBData.GetTableDataType(dbConfName, tableName, column);
	switch(dataType)
	{
		case KvData_Int:
		{
			playerData.SetNum(column, GetNativeCell(6));
		}
		case KvData_Float:
		{
			playerData.SetFloat(column, GetNativeCell(6));
		}
		case KvData_String:
		{
			char result[256]; // TODO: 동적 할당?
			GetNativeString(6, result, sizeof(result));

			playerData.SetString(column, result);
		}
		default:
		{
			ThrowError("dataType is invalid! This should set value that we supported. (%s > %s > column = ''%s'')", dbConfName, tableName, column);
		}
	}
}
