#if defined _db_simple_included
 #endinput
#endif
#define _db_simple_included

#define DBS_NAME_LENGTH         128		// DB config name, table, etc.

enum DBSDataTypes
{
	DBSData_None = 0,
	DBSData_String, // = WString in SourcePawn
	DBSData_Int,
	DBSData_Float,
	DBSData_BigInt,

	DBSData_NUMTYPES
};

// IMPORTANT: DO NOT USE FUNCTIONS WITH PRIVATE TAG! THESE ARE SUPPOSED NOT TO BE USED ON OTHER PLUGINS!

methodmap DBSData < KeyValues {
	#define private public

/**
*	Create new global DB data which collects the information of connections and table datas.
*	Check DBS_OnLoadData function.
*	If you are about to get this data, use Get() function instead of Create().
*/
private static native DBSData Create();
    public static native DBSData Get();

/**
*	Create new table data.
*	Use this when DBS_OnLoadData function is called.
*	Create and Push your table's columns and their data type.
*	If you done, use DBSData.Add function and delete table data Handle.
*	ALL TABLES MUST HAVE AT LEAST A ONE COLUMN WHICH IS PRIMARY KEY AND HAS PLAYER'S STEAM ID(64 Bits, BIGINT).
*	SECOND COLUMN IS UNIQUE INDEX.
*
* 	@param tableName	: 	table name in database.
*	@param noUnique		: 	If true, DBS assumes the table does not have a unique index.
*
*	@return : Generated DBS Table data.
*/
	public static native KeyValues CreateTableData(const char[] tableName, bool noUnique = false);

/**
* 	Push the data of column (name, type) into the table data created from CreateTableData().
*	This will not close tableData. It should be closed manually to avoid memory leak.
*
*	@param tableData	: The data already created from CreateTableData();
*	@param column		: table's column name to add
* 	@noreturn
*/
	public static native void PushTableData(KeyValues tableData, const char[] column, const DBSDataTypes dataType);

/**
*	@param tableData	: The data already created from CreateTableData();
*	@param column		: table's column name to add
*
* 	@return				: If true, The table has no unique index.
*/
	public native bool IsTableNoUnique(const char[] dbConfName, const char[] tableName);
/**
*	Add the table data to specified DB connection.
*	This will try to connect DB. 
*
*	@param dbConfName	: Database defined in databases.cfg
*	@param tableData	: Table data (Check CreateTableData, PushTableData)
*
*	@error				: Connect failed 
*	@noreturn
*/
	public native void Add(const char[] dbConfName, KeyValues tableData);

/**
*	Gets currently collected DB connections.
*
*	@return				:	Array of Databases.
*/
    public native ArrayList GetDBConfNames();

/**
*	Gets currently collected table data in specified DB connection.
*
*	@param dbConfName	:	Database defined in databases.cfg
*
*	@return				:	Array of tables.
*/
    public native ArrayList GetTableNames(const char[] dbConfName);
/**
*	Gets currently collected columns in specified table data in DB connection.
*
*	@param dbConfName	:	Database defined in databases.cfg
*	@param tableName	:	The table name from CreateTableData();
*
*	@return				:	Array of columns.
*/
    public native ArrayList GetColumnNames(const char[] dbConfName, const char[] tableName);

/**
*	Gets specified DB connection.
*
*	@param dbConfName	:	Database defined in databases.cfg
*
*	@return				:	Connection of DB, otherwise returns null.
*/
    public native Database GetConnection(const char[] dbConfName);

	// ...: column names
	// public static native void PushTableIndexSet(KeyValues tableData, const char[] indexSet, int indexType, any ...);

/**
*	Gets table's data type.
*
*	@param dbConfName	: 	Database defined in databases.cfg
*	@param tableName	:	table name
*	@param column		: 	table's column name
*
*	@return: column data type
*/
	public native DBSDataTypes GetTableDataType(const char[] dbConfName, const char[] tableName, const char[] column);
}

methodmap DBSPlayerData < KeyValues {
	#define private public
/**
* 	DO NOT USE THIS FUNCTION ON OTHER PLUGIN.
*	Create Player Data KeyValues.
*	After this, DBS_OnLoadPlayerData Forward function called.
*
*	AGAIN, DO NOT USE THIS FUNCTION ON OTHER PLUGIN.
*/
private static native DBSPlayerData Load(int client);

/**
*	Gets client's player data.
* 	This returns all of client's data.
*
*	@param client		:	client's index
*
*	@return				:	client's player data
*/
    public static native DBSPlayerData GetClientData(int client);

	// public native void GetCurrentIndexSet(const char[] dbConfName, const char[] tableName, char[] indexSet, int buffer);
	// public native void SetCurrentIndexSet(const char[] dbConfName, const char[] tableName, const char[] indexSet);

/**
*	Send update query, writed by current player's data.
*
*	AGAIN, DO NOT USE THIS FUNCTION ON OTHER PLUGIN.
*/
private native void Update();

/**
*	Gets client's player data on specified section.
* 
*	@param dbConfName		:	Database defined in databases.cfg
*	@param tableName		:	table name
*	@param unique			:	unique index name (leave this blank, if the table has no unique index.)
*	@param column			:	table's column name
*	@param value			:	string data to get. (you can leave blank since here, if the data's type is not string.)
*	@param buffer			:	Maximum length of string data.
*	
* 	@return					: 	client's player data on specified section.
*	@error					:	datatype is invalid.
*/
	public native any GetData(const char[] dbConfName, const char[] tableName, const char[] unique = "", const char[] column, char[] value = "", int buffer = 0);
/**
*	Sets client's player data on specified section.
* 	To save string data, use SetStringData() instead.
* 
*	@param dbConfName		:	Database defined in databases.cfg
*	@param tableName		:	table name
*	@param unique			:	unique index name (leave this blank, if the table has no unique index.)
*	@param column			:	table's column name
*	@param value			:	data to save. 
*	
* 	@noreturn
*	@error					:	datatype is invalid.
*/
	public native void SetData(const char[] dbConfName, const char[] tableName, const char[] unique = "", const char[] column, any value);
/**
*	Sets client's player 'string' data on specified section.
* 
*	@param dbConfName		:	Database defined in databases.cfg
*	@param tableName		:	table name
*	@param unique			:	unique index name (leave this blank, if the table has no unique index.)
*	@param column			:	table's column name
*	@param strValue			:	data to save. 
*	
* 	@noreturn
*	@error					:	datatype is invalid.
*/
	public native void SetStringData(const char[] dbConfName, const char[] tableName, const char[] unique = "", const char[] column, char[] strValue);

/**
*	Gets client's unique index on specified section.
* 
*	@param dbConfName		:	Database defined in databases.cfg
*	@param tableName		:	table name
*	
* 	@return					: 	Array (String) of unique index.  
*/
    public native ArrayList GetUniqueNames(const char[] dbConfName, const char[] tableName);
}

/**
*   Called when each map starts. (or plugin reloaded.)
*	When this called, The other plugin's table data can be saved throught Forward function to main data.
*/
forward void DBS_OnLoadData(DBSData data);

/**
    Called when server is loaded player's data.
*/
forward void DBS_OnLoadPlayerData(DBSPlayerData playerData, int client);


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
