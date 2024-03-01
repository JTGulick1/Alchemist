using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OpenInventory : MonoBehaviour
{
    private InputManager inputManager;
    private InventoryManager inventory;
    public bool isOpen = false;
    public bool isclose = false;
    private void Start()
    {
        inputManager = InputManager.Instance;
        inventory = GameObject.FindGameObjectWithTag("Inventory").GetComponent<InventoryManager>();
    }

    private void Update()
    {
        if(isclose == true && inputManager.Interact() == true && isOpen == false)
        {
            isOpen = true;
            inventory.OpenInventory();
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
        isclose = false;
        isOpen = false;
        inventory.CloseInventory();
    }
}
