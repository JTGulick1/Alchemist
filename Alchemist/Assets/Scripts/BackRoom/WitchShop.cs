using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WitchShop : MonoBehaviour, IDataPersistance
{
    private bool isclose;
    private InputManager inputManager;
    private PlayerController player;
    public GameObject witchshop;
    public GameObject Holder;
    public GameObject wItems;
    private BrewingManager brewing;
    public List<Brews> buyingBrews;
    private Currency currency;

    //Save Files
    private bool Perception = false;
    private bool Berserker = false;
    private bool Charm = false;
    private bool ColdResistance = false;
    private bool DeadSilence = false;
    private bool Defence = false;
    private bool EagleEye = false;
    private bool Ethereum = false;
    private bool FireResstance = false;
    private bool Frostbite = false;
    private bool Gills = false;
    private bool Heroism = false;
    private bool Invisibillity = false;
    private bool Levitation = false;
    private bool Luck = false;
    private bool MindClarity = false;
    private bool PhoenixFeather = false;
    private bool PoisonAntidote = false;
    private bool Recall = false;
    private bool Regeneration = false;
    private bool ShadowStep = false;
    private bool ShapeShifting = false;
    private bool Speed = false;
    private bool StoneSkin = false;
    private bool TimeDilation = false;
    private bool WaterBreathing = false;

    public Brews Per1;
    public Brews Ber;
    public Brews Cha;
    public Brews Cold;
    public Brews Dead;
    public Brews Def;
    public Brews Eagle;
    public Brews Eth;
    public Brews Fire;
    public Brews Frost;
    public Brews Gil;
    public Brews Hero;
    public Brews Inv;
    public Brews Lev;
    public Brews Luc;
    public Brews Min;
    public Brews Pho;
    public Brews Pois;
    public Brews Rec;
    public Brews Regen;
    public Brews Sha;
    public Brews Shape;
    public Brews Sped;
    public Brews Stone;
    public Brews Time;
    public Brews Water;

    public AchivementTracker achivement;


    void Start()
    {
        inputManager = InputManager.Instance;
        brewing = GameObject.FindGameObjectWithTag("Brewing").GetComponent<BrewingManager>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        UpdateBrews();
        SpawnBrews();
        witchshop.SetActive(false);
        Holder.SetActive(false);
        achivement = GameObject.FindGameObjectWithTag("Achive").GetComponent<AchivementTracker>();
    }

    void Update()
    {
        if (isclose == true && inputManager.Interact() == true)
        {
            if (player.P2S == true)
            {
                player.player1Action();
            }
            witchshop.SetActive(true);
            Holder.SetActive(true);
            Cursor.lockState = CursorLockMode.None;
        }
    }

    public void SpawnBrews()
    {
        GameObject button;
        for (int i = 0; i < buyingBrews.Count; i++)
        {
            button = Instantiate(wItems, witchshop.transform.position, witchshop.transform.rotation, witchshop.transform);
            button.GetComponent<WItemNumber>().number = i;
            button.GetComponent<Image>().sprite = buyingBrews[i].image;
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            isclose = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            if (player.P2S == true)
            {
                player.player1ActionExit();
            }
            Cursor.lockState = CursorLockMode.Locked;
            witchshop.SetActive(false);
            Holder.SetActive(false);
            isclose = false;
        }
    }

    public int GetPrice(int num)
    {
        return buyingBrews[num].price;
    }

    public void BoughtPot(int num)
    {
        CheckSaves(num);
        currency.Buy(buyingBrews[num].price);
        brewing.avaliableBrews.Add(buyingBrews[num]);
        if (buyingBrews.Count == 0)
        {
            achivement.potions = true;
            achivement.CheckAchivements();
        }
    }

    public void LoadData(GameData data)
    {
        Perception = data.perception1;
        Berserker = data.Berserker;
        Charm = data.Charm;
        ColdResistance = data.ColdResistance;
        DeadSilence = data.DeadSilence;
        Defence = data.Defence;
        EagleEye = data.EagleEye;
        Ethereum = data.Ethereum;
        FireResstance = data.FireResstance;
        Frostbite = data.Frostbite;
        Gills = data.Gills;
        Heroism = data.Heroism;
        Invisibillity = data.Invisibillity;
        Levitation = data.Levitation;
        Luck = data.Luck;
        MindClarity = data.MindClarity;
        PhoenixFeather = data.PhoenixFeather;
        PoisonAntidote = data.PoisonAntidote;
        Recall = data.Recall;
        Regeneration = data.Regeneration;
        ShadowStep = data.ShadowStep;
        ShapeShifting = data.ShapeShifting;
        Speed = data.Spee;
        StoneSkin = data.StoneSkin;
        TimeDilation = data.TimeDilation;
        WaterBreathing = data.WaterBreathing;
    }

    public void SaveData(ref GameData data)
    {
        data.perception1 = Perception;
        data.Berserker = Berserker;
        data.Charm = Charm;
        data.ColdResistance = ColdResistance;
        data.DeadSilence = DeadSilence;
        data.Defence = Defence;
        data.EagleEye = EagleEye;
        data.Ethereum = Ethereum;
        data.FireResstance = FireResstance;
        data.Frostbite = Frostbite;
        data.Gills = Gills;
        data.Heroism = Heroism;
        data.Invisibillity = Invisibillity;
        data.Levitation = Levitation;
        data.Luck = Luck;
        data.MindClarity = MindClarity;
        data.PhoenixFeather = PhoenixFeather;
        data.PoisonAntidote = PoisonAntidote;
        data.Recall = Recall;
        data.Regeneration = Regeneration;
        data.ShadowStep = ShadowStep;
        data.ShapeShifting = ShapeShifting;
        data.Spee = Speed;
        data.StoneSkin = StoneSkin;
        data.TimeDilation = TimeDilation;
        data.WaterBreathing = WaterBreathing;
    }

    private void UpdateBrews()
    {
        if (Perception == true)
        {
            buyingBrews.Remove(Per1);
            brewing.avaliableBrews.Add(Per1);
        }
        if (Berserker == true)
        {
            buyingBrews.Remove(Ber);
            brewing.avaliableBrews.Add(Ber);
        }
        if (Charm == true)
        {
            buyingBrews.Remove(Cha);
            brewing.avaliableBrews.Add(Cha);
        }
        if (ColdResistance == true)
        {
            buyingBrews.Remove(Cold);
            brewing.avaliableBrews.Add(Cold);
        }
        if (DeadSilence == true)
        {
            buyingBrews.Remove(Dead);
            brewing.avaliableBrews.Add(Dead);
        }
        if (Defence == true)
        {
            buyingBrews.Remove(Def);
            brewing.avaliableBrews.Add(Def);
        }
        if (EagleEye == true)
        {
            buyingBrews.Remove(Eagle);
            brewing.avaliableBrews.Add(Eagle);
        }
        if (Ethereum == true)
        {
            buyingBrews.Remove(Eth);
            brewing.avaliableBrews.Add(Eth);
        }
        if (FireResstance == true)
        {
            buyingBrews.Remove(Fire);
            brewing.avaliableBrews.Add(Fire);
        }
        if (Frostbite == true)
        {
            buyingBrews.Remove(Frost);
            brewing.avaliableBrews.Add(Frost);
        }
        if (Gills == true)
        {
            buyingBrews.Remove(Gil);
            brewing.avaliableBrews.Add(Gil);
        }
        if (Heroism == true)
        {
            buyingBrews.Remove(Hero);
            brewing.avaliableBrews.Add(Hero);
        }
        if (Invisibillity == true)
        {
            buyingBrews.Remove(Inv);
            brewing.avaliableBrews.Add(Inv);
        }
        if (Levitation == true)
        {
            buyingBrews.Remove(Lev);
            brewing.avaliableBrews.Add(Lev);
        }
        if (Luck == true)
        {
            buyingBrews.Remove(Luc);
            brewing.avaliableBrews.Add(Luc);
        }
        if (MindClarity == true)
        {
            buyingBrews.Remove(Min);
            brewing.avaliableBrews.Add(Min);
        }
        if (PhoenixFeather == true)
        {
            buyingBrews.Remove(Pho);
            brewing.avaliableBrews.Add(Pho);
        }
        if (PoisonAntidote == true)
        {
            buyingBrews.Remove(Pois);
            brewing.avaliableBrews.Add(Pois);
        }
        if (Recall == true)
        {
            buyingBrews.Remove(Rec);
            brewing.avaliableBrews.Add(Rec);
        }
        if (Regeneration == true)
        {
            buyingBrews.Remove(Regen);
            brewing.avaliableBrews.Add(Regen);
        }
        if (ShadowStep == true)
        {
            buyingBrews.Remove(Sha);
            brewing.avaliableBrews.Add(Sha);
        }
        if (ShapeShifting == true)
        {
            buyingBrews.Remove(Shape);
            brewing.avaliableBrews.Add(Shape);
        }
        if (Speed == true)
        {
            buyingBrews.Remove(Sped);
            brewing.avaliableBrews.Add(Sped);
        }
        if (StoneSkin == true)
        {
            buyingBrews.Remove(Stone);
            brewing.avaliableBrews.Add(Stone);
        }
        if (TimeDilation == true)
        {
            buyingBrews.Remove(Time);
            brewing.avaliableBrews.Add(Time);
        }
        if (WaterBreathing == true)
        {
            buyingBrews.Remove(Water);
            brewing.avaliableBrews.Add(Water);
        }
    }

    private void CheckSaves(int num)
    {
        if (buyingBrews[num].brewName == Per1.brewName)
        {
            Perception = true;
        }
        if (buyingBrews[num].brewName == Ber.brewName)
        {
            Berserker = true;
        }
        if (buyingBrews[num].brewName == Cha.brewName)
        {
            Charm = true;
        }
        if (buyingBrews[num].brewName == Cold.brewName)
        {
            ColdResistance = true;
        }
        if (buyingBrews[num].brewName == Dead.brewName)
        {
            DeadSilence = true;
        }
        if (buyingBrews[num].brewName == Def.brewName)
        {
            Defence = true;
        }
        if (buyingBrews[num].brewName == Eagle.brewName)
        {
            EagleEye = true;
        }
        if (buyingBrews[num].brewName == Eth.brewName)
        {
            Ethereum = true;
        }
        if (buyingBrews[num].brewName == Fire.brewName)
        {
            FireResstance = true;
        }
        if (buyingBrews[num].brewName == Frost.brewName)
        {
            Frostbite = true;
        }
        if (buyingBrews[num].brewName == Gil.brewName)
        {
            Gills = true;
        }
        if (buyingBrews[num].brewName == Hero.brewName)
        {
            Heroism = true;
        }
        if (buyingBrews[num].brewName == Inv.brewName)
        {
            Invisibillity = true;
        }
        if (buyingBrews[num].brewName == Lev.brewName)
        {
            Levitation = true;
        }
        if (buyingBrews[num].brewName == Luc.brewName)
        {
            Luck = true;
        }
        if (buyingBrews[num].brewName == Min.brewName)
        {
            MindClarity = true;
        }
        if (buyingBrews[num].brewName == Pho.brewName)
        {
            PhoenixFeather = true;
        }
        if (buyingBrews[num].brewName == Pois.brewName)
        {
            PoisonAntidote = true;
        }
        if (buyingBrews[num].brewName == Rec.brewName)
        {
            Recall = true;
        }
        if (buyingBrews[num].brewName == Regen.brewName)
        {
            Regeneration = true;
        }
        if (buyingBrews[num].brewName == Sha.brewName)
        {
            ShadowStep = true;
        }
        if (buyingBrews[num].brewName == Shape.brewName)
        {
            ShapeShifting = true;
        }
        if (buyingBrews[num].brewName == Sped.brewName)
        {
            Speed = true;
        }
        if (buyingBrews[num].brewName == Stone.brewName)
        {
            StoneSkin = true;
        }
        if (buyingBrews[num].brewName == Time.brewName)
        {
            TimeDilation = true;
        }
        if (buyingBrews[num].brewName == Water.brewName)
        {
            WaterBreathing = true;
        }
    }
}
