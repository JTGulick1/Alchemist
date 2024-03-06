using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class Currency : MonoBehaviour
{
    public int gold = 0;
    public TMPro.TMP_Text goldTXT;

    void Start()
    {
        goldTXT.text = "Gold: " + gold;
    }

    public void GetGold(int cur)
    {
        gold += cur;
        goldTXT.text = "Gold: " + gold;
    }

    public void BuyGold(int cost)
    {
        gold -= cost;
        goldTXT.text = "Gold:  " + gold;
    }
}
