using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class QuestBoard : MonoBehaviour, IDataPersistance
{
    private BrewingManager brewing;
    private PlayerController player;
    private PlayerController2 player2;

    public int stock = 0;
    public int quota = 30;
    private Brews reqPotion;
    private bool active = false;
    private int brew;
    private int payout;
    public TMPro.TMP_Text questText;
    public AchivementTracker achivement;
    void Start()
    {
        brewing = GameObject.FindGameObjectWithTag("Brewing").GetComponent<BrewingManager>();
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        if (active == false)
        {
            NewQuest();
        }
        questText.text = stock + "/" + quota + " " + reqPotion.brewName;
        questText.gameObject.SetActive(false);
        achivement = GameObject.FindGameObjectWithTag("Achive").GetComponent<AchivementTracker>();
    }

    public void Player2Spawn()
    {
        player2 = GameObject.FindGameObjectWithTag("Player2").GetComponent<PlayerController2>();
    }

    public void NewQuest()
    {
        stock = 0;
        reqPotion = brewing.avaliableBrews[Random.Range(0, brewing.avaliableBrews.Count)];
        payout = reqPotion.price * quota;
    }

    public void QuestComplete()
    {
        player.CompletedQuest(quota);
        achivement.quests++;
        if (achivement.quests == 20 || achivement.quests == 50)
        {
            achivement.CheckAchivements();
        }
        NewQuest();
    }
    public void UpdateText()
    {
        questText.text = stock + "/" + quota + " " + reqPotion.brewName;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            questText.text = stock + "/" + quota + " " + reqPotion.brewName;
            questText.gameObject.SetActive(true);
            player.QuestBoard(reqPotion.physicalForm);
        }
        if (other.tag == "Player2")
        {
            questText.text = stock + "/" + quota + " " + reqPotion.brewName;
            questText.gameObject.SetActive(true);
            player2.QuestBoard(reqPotion.physicalForm);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            questText.gameObject.SetActive(false);
            player.ToFarFromBoard();
        }
        if (other.tag == "Player2")
        {
            questText.gameObject.SetActive(false);
            player2.ToFarFromBoard();
        }
    }

    private void GetBrew()
    {
        brewing = GameObject.FindGameObjectWithTag("Brewing").GetComponent<BrewingManager>();
        for (int i = 0; i < brewing.avaliableBrews.Count; i++)
        {
            if (brew == brewing.avaliableBrews[i].saveInt)
            {
                reqPotion = brewing.avaliableBrews[i];
            }
        }
        UpdateText();
    }

    public void LoadData(GameData data)
    {
        stock = data.bStock;
        brew = data.bPot;
        active = data.active;
        GetBrew();
    }

    public void SaveData(ref GameData data)
    {
        active = true;
        data.bStock = stock;
        data.bPot = reqPotion.saveInt;
        data.active = active;
    }

}
