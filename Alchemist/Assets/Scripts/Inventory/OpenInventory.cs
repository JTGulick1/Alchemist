using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OpenInventory : MonoBehaviour
{
    private InputManager inputManager;
    private InventoryManager inventory;
    private PlayerController player;
    public bool isOpen = false;
    public bool isclose = false;
    public bool isOpen2 = false;
    public bool isclose2 = false;
    private void Start()
    {
        inputManager = InputManager.Instance;
        inventory = GameObject.FindGameObjectWithTag("Inventory").GetComponent<InventoryManager>();
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
    }

    private void Update()
    {
        if(isclose == true && inputManager.Interact() == true && isOpen == false && player.P2S == false)
        {
            isOpen = true;
            inventory.OpenInventory(0);
        }
        if (isclose == true && inputManager.Interact() == true && isOpen == false && player.P2S == true)
        {
            isOpen = true;
            inventory.OpenInventory(1);
        }
        if (isclose2 == true && inputManager.InteractP2() == true && isOpen2 == false && player.P2S == true)
        {
            isOpen2 = true;
            inventory.isP2 = true;
            inventory.OpenInventory(2);
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
            isclose = false;
            isOpen = false;
            inventory.CloseInventory(0);
        }
        if (other.tag == "Player" && player.P2S == true)
        {
            isclose = false;
            isOpen = false;
            inventory.CloseInventory(1);
        }
        if (other.tag == "Player2" && player.P2S == true)
        {
            inventory.isP2 = false;
            isclose2 = false;
            isOpen2 = false;
            inventory.CloseInventory(2);
        }
    }
}
