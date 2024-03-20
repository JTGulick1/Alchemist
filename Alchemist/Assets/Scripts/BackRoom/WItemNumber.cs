using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WItemNumber : MonoBehaviour
{
    public int number = 0;
    private WitchShop inventory;
    private Currency currency;

    private void Start()
    {
        inventory = GameObject.FindGameObjectWithTag("WShop").GetComponent<WitchShop>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
    }
    public void GrabbedItem()
    {
        if (currency.gold >= inventory.GetPrice(number))
        {
            inventory.BoughtPot(number);
            Destroy(this.gameObject);
        }            
    }
}
