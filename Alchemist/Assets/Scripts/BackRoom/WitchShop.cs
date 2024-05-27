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
    }

    private void CheckSaves(int num)
    {
        if (buyingBrews[num].brewName == "Perception Potion")
        {
            Perception = true;
        }
    }
}
