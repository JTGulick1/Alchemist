using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PotionsChest : MonoBehaviour
{
    private PlayerController player;
    private PlayerController2 player2;
    private InputManager inputManager;
    private bool isclose = false;
    private bool isclose2 = false;
    public GameObject potion;
    public List<GameObject> potions = new List<GameObject>();
    private GameObject setingredient;
    public GameObject first;
    public int count = 0;
    public int cap = 30;
    public bool isP2 = false;
    private GameObject temp;

    public GameObject chestUI;
    //public GameObject chestUIp1;
    //public GameObject chestUIp2;


    private void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        chestUI.SetActive(false);
        //chestUIp1.SetActive(false);
        //chestUIp2.SetActive(false); 
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
        if (isclose == true)
        {
            Run(0);
        }
        if (isclose2 == true)
        {
            Run(1);
        }
    }

    public void UpdateInv()
    {
        for (int i = 0; i < potions.Count; i++)
        {
            setingredient = Instantiate(potion, chestUI.transform.position, chestUI.transform.rotation, chestUI.transform);
            //setingredient = Instantiate(potion, invCanP1.transform.position, invCanP1.transform.rotation, invCanP1.transform);
            //setingredient = Instantiate(potion, invCanP2.transform.position, invCanP2.transform.rotation, invCanP2.transform);
            if (i == 0)
            {
                first = setingredient;
            }
            setingredient.GetComponent<ItemNumber>().SetNumber(i);
        }
    }

    public void DeleteInv()
    {
        chestUI.SetActive(true);
        //invCanP1.SetActive(true);
        //invCanP2.SetActive(true);
        foreach (GameObject item in GameObject.FindGameObjectsWithTag("poting"))
        {
            Destroy(item);
        }
        chestUI.SetActive(false);
        //invCanP1.SetActive(false);
        //invCanP2.SetActive(false);
    }
    public void PlacedItem(GameObject potion)
    {
        DeleteInv();
        potions.Add(potion);
        UpdateInv();
    }

    private void Run(int num)
    {
        if (num == 0)
        {
            if (isclose == true && inputManager.Interact() == true
                && player.isHolding == false)
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
            if (isclose2 == true && inputManager.InteractP2() == true
                && player2.carry.GetComponent<BrewSettings>().isPot == true)
            {
                player2.isHolding = false;
                Destroy(player2.carry);
                return;
            }
        }
    }

    public void GrabbedItem(int number)
    {
        if (player.P2S == false)
        {
            player.carry = Instantiate(potions[number], player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
            Destroy(potions[number]);
        }
        /*if (player.P2S == true && isP2 == false)
        {
            player.carry = Instantiate(items[number].physicalForm, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
        }
        if (player.P2S == true && isP2 == true)
        {
            player2.isHolding = true;
            player2.carry = Instantiate(items[number].physicalForm, player2.playerHolder.transform.position, player2.playerHolder.transform.rotation, player2.playerHolder.transform);
        }*/

        potions.RemoveAt(number);
        DeleteInv();
        UpdateInv();
        /* (player.P2S == false)
        {
            CloseInventory(0);
        }
        if (player.P2S == true && isP2 == false)
        {
            CloseInventory(1);
        }
        if (isP2 == true)
        {
            isP2 = false;
            CloseInventory(2);
        }*/
    }

    public void CloseInventory(int num)
    {
        if (num == 0)
        {
            Cursor.lockState = CursorLockMode.Locked;
            chestUI.SetActive(false);
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
        }
    }
}
