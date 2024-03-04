using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InventoryManager : MonoBehaviour
{
    public GameObject invCan;
    public List<Item> items = new List<Item>();
    public int count = 0;
    public int cap = 56;
    public GameObject ingredient;
    private GameObject setingredient;
    private PlayerController player;
    private void Start()
    {
        invCan.SetActive(false);
        UpdateInv();
        count = items.Count;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
    }
    public void UpdateInv()
    {
        for(int i = 0; i < items.Count; i++)
        {
            setingredient = Instantiate(ingredient, invCan.transform.position, invCan.transform.rotation, invCan.transform);
            setingredient.GetComponent<ItemNumber>().SetNumber(i);
            setingredient.GetComponent<Button>().onClick.AddListener(delegate{ setingredient.GetComponent<ItemNumber>().GrabbedItem(setingredient.GetComponent<ItemNumber>().GetNumber()); });
        }
    }
    
    public void DeleteInv()
    {
        foreach (GameObject item in GameObject.FindGameObjectsWithTag("Ing"))
        {
            Destroy(item);
        }
    }

    public void GrabbedItem(int number)
    {
        player.carry = Instantiate(items[number].physicalForm, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
        items.RemoveAt(number);
        DeleteInv();
        UpdateInv();
        CloseInventory();
    }

    public void OpenInventory()
    {
        Cursor.lockState = CursorLockMode.None;
        invCan.SetActive(true);
    }
    public void CloseInventory()
    {
        Cursor.lockState = CursorLockMode.Locked;
        invCan.SetActive(false);
    }
}
