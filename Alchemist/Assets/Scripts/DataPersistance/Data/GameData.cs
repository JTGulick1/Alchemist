using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class GameData
{
    public int coins;
    public int dayCount;
    public int currentday;
    public List<int> inventory = new List<int>();

    public bool perception1;

    public GameData()
    {
        this.coins = 100;
        this.currentday = 0;
        this.dayCount = 0;
        this.perception1 = false;
    }

    public void GetInv(List<Item> items)
    {
        for (int i = 0; i < items.Count; i++)
        {
            inventory.Add(items[i].saveNum);
        }
    }
}
