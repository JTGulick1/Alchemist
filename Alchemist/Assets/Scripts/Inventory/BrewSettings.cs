using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrewSettings : MonoBehaviour
{
    public GameObject C;
    public GameObject B;

    public bool isPot;

    public void ChangeToBrew()
    {
        C.SetActive(true);
        B.SetActive(false);
    }

    public void ChangeToPotion()
    {
        isPot = true;
        C.SetActive(false);
        B.SetActive(true);
    }
}
