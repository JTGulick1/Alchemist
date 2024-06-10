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
    public List<int> potionInv = new List<int>(); // Potions Chest Save


    //Potions
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


    //Relations
    public int Baldwin;
    public int Cedric;
    public int Isolde;
    public int Rowena;

    //Quest Board
    public int bStock;
    public int bPot;
    public bool active;

    public GameData()
    {
        this.coins = 100;
        this.currentday = 0;
        this.dayCount = 0;
        this.perception1 = false;
        this.Baldwin = 0;
        this.Cedric = 0;
        this.Isolde = 0;
        this.Rowena = 0;
        this.bStock = 0;
        this.active = false;
    }

    public void GetInv(List<Item> items)
    {
        for (int i = 0; i < items.Count; i++)
        {
            inventory.Add(items[i].saveNum);
        }
    }

    public void GetPotions(List<GameObject> pots) // To do
    {
        for (int i = 0; i < pots.Count; i++)
        {
            potionInv.Add(pots[i].GetComponent<BrewSettings>().saveInt);
        }
    }
}