#define TEMP_UNIQUE_ID      "TEMP_UNIQUE_ID"

DBSData LoadedDBData;
DBSPlayerData LoadedPlayerData[MAXPLAYERS+1]; // TODO: Realtime connect Socket

Handle OnLoadData, OnPlayerLoadData;
