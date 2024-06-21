using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemNumber : MonoBehaviour
{
    public int number = 0;
    private InventoryManager inventory;
    private PotionsChest potionsChest;
    private PlayerController player;
    private void Start()
    {
        inventory = GameObject.FindGameObjectWithTag("Inventory").GetComponent<InventoryManager>();
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        potionsChest = GameObject.FindGameObjectWithTag("PotionChest").GetComponent<PotionsChest>();
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
        if (player.isHolding == false && inventory.isP2 == false)
        {
            player.isHolding = true;
            inventory.GrabbedItem(number);
            Destroy(this.gameObject);
        }
        if (inventory.isP2 == true && inventory.player2.isHolding == false)
        {
            inventory.player2.isHolding = true;
            inventory.GrabbedItem(number);
            Destroy(this.gameObject);
        }
    }

    public void GrabbedPotion()
    {
        if (potionsChest.isP2 == false)
        {
            player.isHolding = true;
            potionsChest.GrabbedItem(number);
            Destroy(this.gameObject);
        }
        if (potionsChest.isP2 == true)
        {
            potionsChest.GrabbedItem(number);
            Destroy(this.gameObject);
        }
    }
}
