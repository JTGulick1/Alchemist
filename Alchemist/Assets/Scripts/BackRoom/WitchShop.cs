using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WitchShop : MonoBehaviour
{
    private bool isclose;
    private InputManager inputManager;
    public GameObject witchshop;
    private BrewingManager brewing;
    public List<Brews> buyingBrews;
    private Currency currency;
    void Start()
    {
        inputManager = InputManager.Instance;
        brewing = GameObject.FindGameObjectWithTag("Brewing").GetComponent<BrewingManager>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
        witchshop.SetActive(false);
    }

    void Update()
    {
        if (isclose == true && inputManager.Interact() == true)
        {
            witchshop.SetActive(true);
            Cursor.lockState = CursorLockMode.None;
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
        currency.Buy(buyingBrews[num].price);
        brewing.avaliableBrews.Add(buyingBrews[num]);
    }

}
