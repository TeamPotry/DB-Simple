#if defined _db_simple_included
 #endinput
#endif
#define _db_simple_included

methodmap DBSData < KeyValues {
	/*
		Create new DB data. (with update!)
		When this called, The other plugin's table data is saved throught Forward function to main data.
		Check DBS_OnLoadData function.

		ALL TABLES ARE MUST HAVE FIRST COLUMN THAT IS PRIMARY KEY AND HAS PLAYER'S STEAM ID(64 Bits).
		SECOND COLUMN IS UNIQUE INDEX.

		DO NOT USE THIS FUNCTION ON OTHER PLUGIN. THIS IS ONLY FOR MAIN PLUGIN TO CALL.
        If you are about to function of this, use Get function first.
	*/
	public static native DBSData Create();
    public static native DBSData Get();

	/*
		Create new Table Data.
		Use this when DBS_OnLoadData function is called.

		Create and Push your table's columns and their data type.
		If you done, use DBSData.Add function and delete table data Handle.

		@param tableData: CreateTableData's return value
		@param column: table's column name to add
	*/
	public static native KeyValues CreateTableData(const char[] tableName, bool noUnique = false);
	public static native void PushTableData(KeyValues tableData, const char[] column, const KvDataTypes dataType);

	public native void Add(const char[] dbConfName, KeyValues tableData);

	// ...: column names
	// public static native void PushTableIndexSet(KeyValues tableData, const char[] indexSet, int indexType, any ...);

	/*
		Get table's data type.

		@param dbConfName: Database Config name. (for connection)
		@param tableName: table name
		@param column: table's column name

		@return: column data type
	*/
	public native KvDataTypes GetTableDataType(const char[] dbConfName, const char[] tableName, const char[] column);
}

methodmap DBSPlayerData < KeyValues {
	/*
		Create Player Data KeyValues.
		On use this, DBS_OnLoadPlayerData Forward function called.

		DO NOT USE THIS FUNCTION ON OTHER PLUGIN. THIS IS ONLY FOR MAIN PLUGIN TO CALL.
	*/
	public static native DBSPlayerData Load(int client);

    /*
        Get client's player data.

        @param client: client's index

        @return: client's player data
    */
    public static native DBSPlayerData GetClientData(int client);

	// public native void GetCurrentIndexSet(const char[] dbConfName, const char[] tableName, char[] indexSet, int buffer);
	// public native void SetCurrentIndexSet(const char[] dbConfName, const char[] tableName, const char[] indexSet);

	/*
		Send update query, writed by player's data.

		DO NOT USE THIS FUNCTION ON OTHER PLUGIN. THIS IS ONLY FOR MAIN PLUGIN TO CALL.
	*/
	public native void Update();

	public native any GetData(const char[] dbConfName, const char[] tableName, const char[] unique = "", const char[] column, char[] value = "", int buffer = 0);
	public native void SetData(const char[] dbConfName, const char[] tableName, const char[] unique = "", const char[] column, any value);
	public native void SetStringData(const char[] dbConfName, const char[] tableName, const char[] unique = "", const char[] column, char[] strValue);
}



public SharedPlugin __pl_db_simple=
{
	name="db_simple",
	file="db_simple.smx",
	#if defined REQUIRE_PLUGIN
		required=1,
	#else
		required=0,
	#endif
};

#if !defined REQUIRE_PLUGIN
public __pl_db_simple_SetNTVOptional()
{
    MarkNativeAsOptional("DBSData.Create");
    MarkNativeAsOptional("DBSData.Get");
    MarkNativeAsOptional("DBSData.CreateTableData");
    MarkNativeAsOptional("DBSData.PushTableData");
    MarkNativeAsOptional("DBSData.Add");
    MarkNativeAsOptional("DBSData.GetTableDataType");

    MarkNativeAsOptional("DBSPlayerData.Load");
    MarkNativeAsOptional("DBSData.GetClientData");
    MarkNativeAsOptional("DBSPlayerData.Update");
    MarkNativeAsOptional("DBSPlayerData.GetData");
    MarkNativeAsOptional("DBSPlayerData.SetData");
    MarkNativeAsOptional("DBSPlayerData.SetStringData");
}
#endif
