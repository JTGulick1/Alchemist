using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShopManager : MonoBehaviour
{
    public GameObject shopCan;
    public List<Item> items = new List<Item>();
    private InventoryManager inventory;
    private InputManager inputManager;
    private Currency currency;

    public bool isOpen = false;
    public bool isclose = false;

    void Start()
    {
        shopCan.SetActive(false);
        inputManager = InputManager.Instance;
        inventory = GameObject.FindGameObjectWithTag("Inventory").GetComponent<InventoryManager>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
    }

    void Update()
    {
        if (isclose == true && inputManager.Interact() == true && isOpen == false)
        {
            isOpen = true;
            OpenShop();
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

    private void OpenShop()
    {
        Cursor.lockState = CursorLockMode.None;
        shopCan.SetActive(true);
    }

    private void CloseShop()
    {
        Cursor.lockState = CursorLockMode.Locked;
        shopCan.SetActive(false);
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
        isclose = false;
        isOpen = false;
        CloseShop();
    }
}
