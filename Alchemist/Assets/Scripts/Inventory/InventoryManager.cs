using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InventoryManager : MonoBehaviour
{
    public GameObject invCan;
    public GameObject invCanP1;
    public GameObject invCanP2;
    public List<Item> items = new List<Item>();
    public int count = 0;
    public int cap = 56;
    public GameObject ingredient;
    private GameObject setingredient;
    public GameObject first;
    private PlayerController player;
    private PlayerController2 player2;
    public bool isP2 = false;
    private void Start()
    {
        invCan.SetActive(false);
        invCanP1.SetActive(false);
        invCanP2.SetActive(false);
        UpdateInv();
        count = items.Count;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
    }
    public void UpdateInv()
    {
        for (int i = 0; i < items.Count; i++)
        {
            setingredient = Instantiate(ingredient, invCan.transform.position, invCan.transform.rotation, invCan.transform);
            setingredient = Instantiate(ingredient, invCanP1.transform.position, invCanP1.transform.rotation, invCanP1.transform);
            setingredient = Instantiate(ingredient, invCanP2.transform.position, invCanP2.transform.rotation, invCanP2.transform);
            if (i == 0)
            {
                first = setingredient;
            }
            setingredient.GetComponent<ItemNumber>().SetNumber(i);
        }
    }

    public void DeleteInv()
    {
        invCan.SetActive(true);
        invCanP1.SetActive(true);
        invCanP2.SetActive(true);
        foreach (GameObject item in GameObject.FindGameObjectsWithTag("Ing"))
        {
            Destroy(item);
        }
        invCan.SetActive(false);
        invCanP1.SetActive(false);
        invCanP2.SetActive(false);
    }

    public void BoughtItem(Item item)
    {
        DeleteInv();
        items.Add(item);
        UpdateInv();
    }

    public void Joined()
    {
        player2 = GameObject.FindGameObjectWithTag("Player2").GetComponent<PlayerController2>();
    }

    public void GrabbedItem(int number)
    {
        if (player.P2S == false)
        {
            player.carry = Instantiate(items[number].physicalForm, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
        }
        if (player.P2S == true && isP2 == false)
        {
            player.carry = Instantiate(items[number].physicalForm, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
        }
        if (player.P2S == true && isP2 == true)
        {
            player2.isHolding = true;
            player2.carry = Instantiate(items[number].physicalForm, player2.playerHolder.transform.position, player2.playerHolder.transform.rotation, player2.playerHolder.transform);
        }

        items.RemoveAt(number);
        DeleteInv();
        UpdateInv();
        if (player.P2S == false)
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
        }
    }

    public void OpenInventory(int num)
    {
        if (num == 0)
        {
            Cursor.lockState = CursorLockMode.None;
            invCan.SetActive(true);
        }
        if (num == 1)
        {
            Cursor.lockState = CursorLockMode.None;
            invCanP1.SetActive(true);
        }
        if (num == 2)
        {
            player2.selected(first);
            invCanP2.SetActive(true);
        }
    }
    public void CloseInventory(int num)
    {
        if (num == 0)
        {
            Cursor.lockState = CursorLockMode.Locked;
            invCan.SetActive(false);
        }
        if (num == 1)
        {
            Cursor.lockState = CursorLockMode.Locked;
            invCanP1.SetActive(false);
        }
        if (num == 2)
        {
            invCanP2.SetActive(false);
        }

    }
}
