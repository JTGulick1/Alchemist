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
    public bool Berserker;
    public bool Charm;
    public bool ColdResistance;
    public bool DeadSilence;
    public bool Defence;
    public bool EagleEye;
    public bool Ethereum;
    public bool FireResstance;
    public bool Frostbite;
    public bool Gills;
    public bool Heroism;
    public bool Invisibillity;
    public bool Levitation;
    public bool Luck;
    public bool MindClarity;
    public bool PhoenixFeather;
    public bool PoisonAntidote;
    public bool Recall;
    public bool Regeneration;
    public bool ShadowStep;
    public bool ShapeShifting;
    public bool Spee;
    public bool StoneSkin;
    public bool TimeDilation;
    public bool WaterBreathing;

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
