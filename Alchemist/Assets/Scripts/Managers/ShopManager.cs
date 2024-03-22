using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShopManager : MonoBehaviour
{
    public GameObject shopCan;
    public GameObject shopCanP1;
    public GameObject shopCanP2;
    public List<Item> items = new List<Item>();
    private InventoryManager inventory;
    private InputManager inputManager;
    private Currency currency;
    private PlayerController player;
    public bool isOpen = false;
    public bool isclose = false;
    public bool isOpen2 = false;
    public bool isclose2 = false;

    void Start()
    {
        shopCan.SetActive(false);
        shopCanP1.SetActive(false);
        shopCanP2.SetActive(false);
        inputManager = InputManager.Instance;
        inventory = GameObject.FindGameObjectWithTag("Inventory").GetComponent<InventoryManager>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
    }

    void Update()
    {
        if (isclose == true && inputManager.Interact() == true && isOpen == false && player.P2S == false)
        {
            isOpen = true;
            OpenShop(0);
        }
        if (isclose == true && inputManager.Interact() == true && isOpen == false && player.P2S == true)
        {
            isOpen = true;
            OpenShop(1);
        }
        if (isclose2 == true && inputManager.InteractP2() == true && isOpen2 == false && player.P2S == true)
        {
            isOpen = true;
            OpenShop(2);
        }
    }

    public void Bought(int number)
    {
        if (currency.gold >= items[number].cost)
        {
            currency.Buy(items[number].cost);
            inventory.BoughtItem(items[number]);
        }
    }

    private void OpenShop(int num)
    {
        if (num == 0)
        {
            Cursor.lockState = CursorLockMode.None;
            shopCan.SetActive(true);
        }
        if (num == 1)
        {
            Cursor.lockState = CursorLockMode.None;
            shopCanP1.SetActive(true);
        }
        if (num == 2)
        {
            Cursor.lockState = CursorLockMode.None;
            shopCanP2.SetActive(true);
        }

    }

    private void CloseShop(int num)
    {
        if (num == 0)
        {
            Cursor.lockState = CursorLockMode.Locked;
            shopCan.SetActive(false);
        }
        if (num == 1)
        {
            Cursor.lockState = CursorLockMode.Locked;
            shopCanP1.SetActive(false);
        }
        if (num == 2)
        {
            Cursor.lockState = CursorLockMode.Locked;
            shopCanP2.SetActive(false);
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
        if (other.tag == "Player" && player.P2S == false)
        {
            isclose = false;
            isOpen = false;
            CloseShop(0);
        }
        if (other.tag == "Player" && player.P2S == true)
        {
            isclose = false;
            isOpen = false;
            CloseShop(1);
        }
        if (other.tag == "Player2" && player.P2S == true)
        {
            isclose2 = false;
            isOpen2 = false;
            CloseShop(2);
        }
    }
}
