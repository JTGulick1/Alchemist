using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OpenInventory : MonoBehaviour
{
    public InputManager inputManager;
    public InventoryManager inventory;
    public bool isOpen = false;
    private void Start()
    {
        inputManager = InputManager.Instance;
        inventory = GameObject.FindGameObjectWithTag("Inventory").GetComponent<InventoryManager>();
    }

    private void OnTriggerStay(Collider other)
    {
        if (other.tag == "Player" && inputManager.Interact() == true && isOpen == false)
        {
            Debug.Log("Open");
            isOpen = true;
            inventory.OpenInventory();
            return;
        }
        if (other.tag == "Player" && inputManager.Interact() == true && isOpen == true)
        {
            Debug.Log("Close");
            isOpen = false;
            inventory.CloseInventory();
            return;
        }
    }
}
