using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AchivementTracker : MonoBehaviour, IDataPersistance
{
    public bool potions = false;
    public bool bals = false;
    public bool iceGolem = false;
    public bool fireGolem = false;
    public bool earthGolem = false;
    public int pats = 0;
    public int quests = 0;
    public int totalGold = 0;
    public int maxR = 0;
    public Mirror mirror;

    public void CheckAchivements()
    {
        if (pats >= 20)//
        {
            mirror.achive[0] = true;
        }
        if (pats >= 50)//
        {
            mirror.achive[1] = true;
        }
        if (pats >= 100)//
        {
            mirror.achive[2] = true;
        }
        if (pats >= 200)//
        {
            mirror.achive[3] = true;
        }
        if (pats >= 400)//
        {
            mirror.achive[4] = true;
        }
        if (potions == true)//
        {
            mirror.achive[5] = true;
        }
        if (quests >= 20)//
        {
            mirror.achive[6] = true;
        }
        if (quests >= 50)//
        {
            mirror.achive[7] = true;
        }
        if (bals == true)//
        {
            mirror.achive[8] = true;
        }
        if (totalGold >= 10000)//
        {
            mirror.achive[9] = true;
        }
        if (iceGolem == true)// Implement With Fighting Update
        {
            mirror.achive[10] = true;
        }
        if (fireGolem == true)// Implement With Fighting Update
        {
            mirror.achive[11] = true;
        }
        if (earthGolem == true)// Implement With Fighting Update
        {
            mirror.achive[12] = true;
        }
        if (maxR >= 5)//
        {
            mirror.achive[13] = true;
        }
        if (maxR >= 10)//
        {
            mirror.achive[14] = true;
        }
    }


    public void LoadData(GameData data)
    {
        potions = data.potions;
        bals = data.bals;
        iceGolem = data.iceGolem;
        fireGolem = data.fireGolem;
        earthGolem = data.earthGolem;
        pats = data.pats;
        quests = data.quests;
        totalGold = data.totalGold;
        maxR = data.maxR;
    }
    public void SaveData(ref GameData data)
    {
        data.potions = potions;
        data.bals = bals;
        data.iceGolem = iceGolem;
        data.fireGolem = fireGolem;
        data.earthGolem = earthGolem;
        data.pats = pats;
        data.quests = quests;
        data.totalGold = totalGold;
        data.maxR = maxR;
    }
}
