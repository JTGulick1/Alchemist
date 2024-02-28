using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class InventoryManager : MonoBehaviour
{
    public GameObject invCan;
    public List<Item> items = new List<Item>();
    public int cap = 30;
    private void Start()
    {
        invCan.SetActive(false);
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
