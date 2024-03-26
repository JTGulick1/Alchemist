using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[System.Serializable]
public class GameData
{
    public int coins;
    public int dayCount;
    public int currentday;
    public List<Item> items = new List<Item>();


    public GameData()
    {
        this.coins = 100;
        this.currentday = 0;
        this.dayCount = 0;
    }
}
