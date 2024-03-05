using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemNumber : MonoBehaviour
{
    public int number = 0;
    private InventoryManager inventory;
    private PlayerController player;
    private void Start()
    {
        inventory = GameObject.FindGameObjectWithTag("Inventory").GetComponent<InventoryManager>();
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
    }

    public void SetNumber(int num)
    {
        number = num;
    }

    public int GetNumber()
    {
        return number;
    }


    public void GrabbedItem()
    {
        if(player.isHolding == false)
        {
            player.isHolding = true;
            inventory.GrabbedItem(number);
            Destroy(this.gameObject);
        }
    }
}
