using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
public class PotionsChest : MonoBehaviour, IDataPersistance
{
    private PlayerController player;
    public PlayerController2 player2;
    private InputManager inputManager;
    private bool isclose = false;
    private bool isclose2 = false;
    public GameObject potion;
    public List<GameObject> potions = new List<GameObject>();
    public List<GameObject> avaPotions = new List<GameObject>();
    public BrewingManager brewing;
    private GameObject setingredient;
    public GameObject first;
    public int count = 0;
    public int cap = 30;
    public bool isP2 = false;
    private GameObject temp;

    public GameObject chestUI;
    public GameObject chestUIp1;
    public GameObject chestUIp2;
    private GameObject tempSave;

    private bool justGrabbed = false;

    private void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        brewing = GameObject.FindGameObjectWithTag("Brewing").GetComponent<BrewingManager>();
        chestUI.SetActive(false);
        UpdateInv();
        chestUIp1.SetActive(false);
        chestUIp2.SetActive(false);
    }

    public void Joined()
    {
        player2 = GameObject.FindGameObjectWithTag("Player2").GetComponent<PlayerController2>();
    }

    private void Update()
    {
        if (player.P2S == true && player2 == null)
        {
            Joined();
        }
        if (isclose == true && player.P2S == false)
        {
            Run(0);
        }
        if (isclose == true && player.P2S == true)
        {
            Run(1);
        }
        if (isclose2 == true)
        {
            Run(2);
        }
    }

    public void UpdateInv()
    {
        for (int i = 0; i < potions.Count; i++)
        {
            setingredient = Instantiate(potion, chestUI.transform.position, chestUI.transform.rotation, chestUI.transform);
            setingredient.GetComponent<Image>().sprite = potions[i].GetComponent<BrewSettings>().image;
            setingredient.GetComponent<ItemNumber>().SetNumber(i);
            setingredient = Instantiate(potion, chestUIp1.transform.position, chestUIp1.transform.rotation, chestUIp1.transform);
            setingredient.GetComponent<Image>().sprite = potions[i].GetComponent<BrewSettings>().image;
            setingredient.GetComponent<ItemNumber>().SetNumber(i);
            setingredient = Instantiate(potion, chestUIp2.transform.position, chestUIp2.transform.rotation, chestUIp2.transform);
            setingredient.GetComponent<Image>().sprite = potions[i].GetComponent<BrewSettings>().image;
            setingredient.GetComponent<ItemNumber>().SetNumber(i);
            if (i == 0)
            {
                first = setingredient;
            }
        }
    }

    public void DeleteInv()
    {
        chestUI.SetActive(true);
        chestUIp1.SetActive(true);
        chestUIp2.SetActive(true);
        foreach (GameObject item in GameObject.FindGameObjectsWithTag("poting"))
        {
            Destroy(item);
        }
        chestUI.SetActive(false);
        chestUIp1.SetActive(false);
        chestUIp2.SetActive(false);
    }
    public void PlacedItem(GameObject potion)
    {
        DeleteInv();
        potions.Add(potion);
        UpdateInv();
    }

    private void Run(int num)
    {
        if (justGrabbed == false)
        {
            if (num == 0)
            {
                if (isclose == true && inputManager.Interact() == true
                    && player.isHolding == false && player.P2S == false)
                {
                    Cursor.lockState = CursorLockMode.None;
                    chestUI.SetActive(true);
                    return;
                }
                if (isclose == true && inputManager.Interact() == true
                    && player.carry.GetComponent<BrewSettings>().isPot == true)
                {
                    player.isHolding = false;
                    temp = Instantiate(player.carry, this.transform.position, this.transform.rotation);
                    PlacedItem(temp);
                    Destroy(player.carry);
                    return;
                }
            }
            if (num == 1)
            {
                if (isclose == true && inputManager.Interact() == true
                    && player.isHolding == false && player.P2S == true)
                {
                    Cursor.lockState = CursorLockMode.None;
                    chestUIp1.SetActive(true);
                    return;
                }
                if (isclose == true && inputManager.Interact() == true
                    && player.carry.GetComponent<BrewSettings>().isPot == true)
                {
                    player.isHolding = false;
                    temp = Instantiate(player.carry, this.transform.position, this.transform.rotation);
                    PlacedItem(temp);
                    Destroy(player.carry);
                    return;
                }
            }
            if (num == 2)
            {
                if (isclose2 == true && inputManager.InteractP2() == true
                    && player2.isHolding == false)
                {
                    chestUIp2.SetActive(true);
                    player2.selected(first);
                    return;
                }
                if (isclose2 == true && inputManager.InteractP2() == true
                    && player2.carry.GetComponent<BrewSettings>().isPot == true)
                {
                    player2.isHolding = false;
                    temp = Instantiate(player2.carry, this.transform.position, this.transform.rotation);
                    PlacedItem(temp);
                    Destroy(player2.carry);
                    return;
                }
            }
        }
    }

    public void GrabbedItem(int number)
    {
        justGrabbed = true;
        if (player.P2S == false)
        {
            player.carry = Instantiate(potions[number], player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
        }
        if (player.P2S == true && isP2 == false)
        {
            player.carry = Instantiate(potions[number], player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
        }
        if (isP2 == true)
        {
            Debug.Log("Player 2");
            player2.isHolding = true;
            player2.carry = Instantiate(potions[number], player2.playerHolder.transform.position, player2.playerHolder.transform.rotation, player2.playerHolder.transform);
        }

        Destroy(potions[number]);
        potions.RemoveAt(number);
        DeleteInv();
        UpdateInv();
        if (player.P2S == false)
        {
            CloseInventory(0);
        }
        if (player.P2S == true && isP2 == false)
        {
            CloseInventory(1);
        }
        if (isP2 == true)
        {
            CloseInventory(2);
        }
    }

    public void CloseInventory(int num)
    {
        if (num == 0)
        {
            Cursor.lockState = CursorLockMode.Locked;
            chestUI.SetActive(false);
        }
        if (num == 1)
        {
            Cursor.lockState = CursorLockMode.Locked;
            chestUIp1.SetActive(false);
        }
        if (num == 2)
        {
            chestUIp2.SetActive(false);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            isclose = true;
        }
        if (other.tag == "Player2")
        {
            isP2 = true;
            isclose2 = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            CloseInventory(0);
            CloseInventory(1);
            isclose = false;
        }
        if (other.tag == "Player2")
        {
            isclose2 = false;
            isP2 = false;
            CloseInventory(2);
        }
        justGrabbed = false;
    }

    public void LoadData(GameData data)
    {
        brewing = GameObject.FindGameObjectWithTag("Brewing").GetComponent<BrewingManager>();
        for (int i = 0; i < data.potionInv.Count; i++)
        {
            for (int j = 0; j < brewing.avaliableBrews.Count; j++)
            {
                if (data.potionInv[i] == brewing.avaliableBrews[j].saveInt)
                {
                    temp = Instantiate(brewing.avaliableBrews[j].physicalForm, this.transform.position, this.transform.rotation);
                    potions.Add(temp);
                    temp.GetComponent<BrewSettings>().ChangeToPotion();
                }
            }
        }
    }

    public void SaveData(ref GameData data)
    {
        data.GetPotions(potions);
    }
}
