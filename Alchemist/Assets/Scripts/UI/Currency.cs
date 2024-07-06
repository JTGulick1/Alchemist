using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class Currency : MonoBehaviour, IDataPersistance
{
    public int gold = 0;
    public TMPro.TMP_Text goldTXT;
    public AchivementTracker achivement;

    void Start()
    {
        goldTXT.text = "Gold: " + gold;
        achivement = GameObject.FindGameObjectWithTag("Achive").GetComponent<AchivementTracker>();
    }

    public void LoadData(GameData data)
    {
        gold = data.coins;
    }

    public void SaveData(ref GameData data)
    {
        data.coins = gold;
    }

    public void GetGold(int cur)
    {
        gold += cur;
        achivement.totalGold += cur;
        if (achivement.totalGold >= 10000 && achivement.totalGold <= 11000)
        {
            achivement.CheckAchivements();
        }
        goldTXT.text = "Gold: " + gold;
    }

    public void Buy(int cost)
    {
        gold -= cost;
        goldTXT.text = "Gold:  " + gold;
    }
}
