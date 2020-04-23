#pragma semicolon 1
#include <sourcemod> 
#include <sdktools>
#include <store> 
#include <zephstocks> 
#include <fpvm_interface>

#pragma newdecls required
enum CustomModel
{
	String:szModel[PLATFORM_MAX_PATH],
	String:szWorldModel[PLATFORM_MAX_PATH],
	String:szDropModel[PLATFORM_MAX_PATH],
	String:weaponentity[32],
	iSlot,
	iCacheID,
	iCacheIDWorldModel
}

int g_eCustomModel[STORE_MAX_ITEMS][CustomModel];
int g_iCustomModels = 0;

public void OnPluginStart() 
{
	Store_RegisterHandler("CustomModel", "model", CustomModelOnMapStart, CustomModelReset, CustomModelConfig, CustomModelEquip, CustomModelRemove, true); 
}


public void CustomModelOnMapStart() 
{
	for(int i=0;i<g_iCustomModels;++i)
	{
		g_eCustomModel[i][iCacheID] = PrecacheModel2(g_eCustomModel[i][szModel], true);
		Downloader_AddFileToDownloadsTable(g_eCustomModel[i][szModel]);
		
		if(g_eCustomModel[i][szWorldModel][0]!=0)
		{
			g_eCustomModel[i][iCacheIDWorldModel] = PrecacheModel2(g_eCustomModel[i][szWorldModel], true);
			Downloader_AddFileToDownloadsTable(g_eCustomModel[i][szWorldModel]);
			
			if(g_eCustomModel[i][iCacheIDWorldModel] ==0)
				g_eCustomModel[i][iCacheIDWorldModel] = -1;
		}
		
		if(g_eCustomModel[i][szDropModel][0]!=0)
		{
			if(!IsModelPrecached(g_eCustomModel[i][szDropModel]))
			{
				PrecacheModel2(g_eCustomModel[i][szDropModel], true);
				Downloader_AddFileToDownloadsTable(g_eCustomModel[i][szDropModel]);
			}
		}
	}
} 


public void CustomModelReset() 
{ 
	g_iCustomModels = 0; 
}

public int CustomModelConfig(Handle &kv, int itemid) 
{
	Store_SetDataIndex(itemid, g_iCustomModels);
	KvGetString(kv, "model", g_eCustomModel[g_iCustomModels][szModel], PLATFORM_MAX_PATH);
	KvGetString(kv, "worldmodel", g_eCustomModel[g_iCustomModels][szWorldModel], PLATFORM_MAX_PATH);
	KvGetString(kv, "dropmodel", g_eCustomModel[g_iCustomModels][szDropModel], PLATFORM_MAX_PATH);
	KvGetString(kv, "entity", g_eCustomModel[g_iCustomModels][weaponentity], 32);
	g_eCustomModel[g_iCustomModels][iSlot] = KvGetNum(kv, "slot");
	
	if(FileExists(g_eCustomModel[g_iCustomModels][szModel], true))
	{
		++g_iCustomModels;
		
		for(int i=0;i<g_iCustomModels;++i)
		{
			if(!IsModelPrecached(g_eCustomModel[i][szModel]))
			{
				g_eCustomModel[i][iCacheID] = PrecacheModel2(g_eCustomModel[i][szModel], true);
				Downloader_AddFileToDownloadsTable(g_eCustomModel[i][szModel]);
				//LogMessage("Precached %i %s",g_eCustomModel[i][iCacheID],g_eCustomModel[i][szModel]);
			}
			if(g_eCustomModel[i][szWorldModel][0]!=0)
			{
				if(!IsModelPrecached(g_eCustomModel[i][szWorldModel]))
				{	
					g_eCustomModel[i][iCacheIDWorldModel] = PrecacheModel2(g_eCustomModel[i][szWorldModel], true);
					Downloader_AddFileToDownloadsTable(g_eCustomModel[i][szWorldModel]);
					//LogMessage("Precached %i %s",g_eCustomModel[i][iCacheIDWorldModel],g_eCustomModel[i][szWorldModel]);
				}
				if(g_eCustomModel[i][szDropModel][0]!=0)
				{
					if(!IsModelPrecached(g_eCustomModel[i][szDropModel]))
					{
						PrecacheModel2(g_eCustomModel[i][szDropModel], true);
						Downloader_AddFileToDownloadsTable(g_eCustomModel[i][szDropModel]);
					}
				}
			}
		}
		
		return true;
	}
	return false;
}

public int CustomModelEquip(int client, int id)
{
	PrintToChat(client,"有些武器无法与贴纸兼容,如果遇到贴图错误请先使用原版武器再装备.");
	int m_iData = Store_GetDataIndex(id);
	if(g_eCustomModel[m_iData][szDropModel]!=0)
		FPVMI_SetClientModel(client, g_eCustomModel[m_iData][weaponentity], g_eCustomModel[m_iData][iCacheID], g_eCustomModel[m_iData][iCacheIDWorldModel], g_eCustomModel[m_iData][szDropModel]);
	else
		FPVMI_SetClientModel(client, g_eCustomModel[m_iData][weaponentity], g_eCustomModel[m_iData][iCacheID], g_eCustomModel[m_iData][iCacheIDWorldModel], g_eCustomModel[m_iData][szWorldModel]);
	return g_eCustomModel[m_iData][iSlot];
}

public int CustomModelRemove(int client, int id) 
{
	int m_iData = Store_GetDataIndex(id);
	
	FPVMI_RemoveViewModelToClient(client, g_eCustomModel[m_iData][weaponentity]);
	if(g_eCustomModel[m_iData][szWorldModel][0]!=0)
	{
		FPVMI_RemoveWorldModelToClient(client, g_eCustomModel[m_iData][weaponentity]);
	}
	if(g_eCustomModel[m_iData][szDropModel][0]!=0)
	{
		FPVMI_RemoveDropModelToClient(client, g_eCustomModel[m_iData][weaponentity]);
	}
	
	return g_eCustomModel[m_iData][iSlot];
}




public void OnMapStart() //Precache possible bug re check
{
	if(g_iCustomModels > 0)
	{
		for(int i=0;i<g_iCustomModels;++i)
		{
			if(!IsModelPrecached(g_eCustomModel[i][szModel]))
			{
				g_eCustomModel[i][iCacheID] = PrecacheModel2(g_eCustomModel[i][szModel], true);
				Downloader_AddFileToDownloadsTable(g_eCustomModel[i][szModel]);
			}
			
			if(g_eCustomModel[i][szWorldModel][0]!=0)
			{
				if(!IsModelPrecached(g_eCustomModel[i][szWorldModel]))
				{
					g_eCustomModel[i][iCacheIDWorldModel] = PrecacheModel2(g_eCustomModel[i][szWorldModel], true);
					Downloader_AddFileToDownloadsTable(g_eCustomModel[i][szWorldModel]);
					
					if(g_eCustomModel[i][iCacheIDWorldModel] ==0)
						g_eCustomModel[i][iCacheIDWorldModel] = -1;
				}
			}
			
			if(g_eCustomModel[i][szDropModel][0]!=0)
			{
				if(!IsModelPrecached(g_eCustomModel[i][szDropModel]))
				{	
					PrecacheModel2(g_eCustomModel[i][szDropModel], true);
					Downloader_AddFileToDownloadsTable(g_eCustomModel[i][szDropModel]);
				}
			}
		}
	}
} 



