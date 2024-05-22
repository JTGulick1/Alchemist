using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class QuestBoard : MonoBehaviour
{
    private BrewingManager brewing;
    private PlayerController player;
    private PlayerController2 player2;

    public int stock = 0;
    public int quota = 30;
    private Brews reqPotion;
    private int payout;
    public TMPro.TMP_Text questText;
    void Start()
    {
        brewing = GameObject.FindGameObjectWithTag("Brewing").GetComponent<BrewingManager>();
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        NewQuest();
        questText.text = stock + "/" + quota + " " + reqPotion.brewName;
        questText.gameObject.SetActive(false);
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
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            questText.gameObject.SetActive(false);
            player.ToFarFromBoard();
        }
    }
}
