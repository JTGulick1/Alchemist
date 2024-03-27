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
    public GameObject wItems;
    private BrewingManager brewing;
    public List<Brews> buyingBrews;
    private Currency currency;

    //Save Files
    private bool Perception1 = false;

    public Brews Per1;

    void Start()
    {
        inputManager = InputManager.Instance;
        brewing = GameObject.FindGameObjectWithTag("Brewing").GetComponent<BrewingManager>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        UpdateBrews();
        SpawnBrews();
        witchshop.SetActive(false);
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
        Perception1 = data.perception1;
    }

    public void SaveData(ref GameData data)
    {
        data.perception1 = Perception1;
    }

    private void UpdateBrews()
    {
        if (Perception1 == true)
        {
            buyingBrews.Remove(Per1);
            brewing.avaliableBrews.Add(Per1);
        }
    }

    private void CheckSaves(int num)
    {
        if (buyingBrews[num].brewName == "Perception Potion")
        {
            Perception1 = true;
        }
    }
}
