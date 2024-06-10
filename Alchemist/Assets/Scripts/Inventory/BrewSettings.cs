using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrewSettings : MonoBehaviour
{
    public string title = "name";
    public string temp = "";
    public Sprite image;
    public GameObject C;
    public GameObject B;
    public int price = 15;
    public bool isPot;
    public int saveInt;
    private void Start()
    {
        temp = title;
    }

    public void ChangeToBrew()
    {
        C.SetActive(true);
        B.SetActive(false);
        temp += " Brew";
    }

    public void ChangeToPotion()
    {
        isPot = true;
        C.SetActive(false);
        B.SetActive(true);
        temp = title;
    }
}
