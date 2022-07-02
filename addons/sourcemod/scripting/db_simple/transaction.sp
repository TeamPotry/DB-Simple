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