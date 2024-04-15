using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Book : MonoBehaviour
{
    private int baldwin = 0;
    private int Cedric = 0;
    private int Isolde = 0;
    private int Rowena = 0;
    public GameObject Heart;

    public GameObject Bald;
    public GameObject Ced;
    public GameObject Iso;
    public GameObject Row;

    public GameObject relationPage;
    public GameObject potion1Page;

    private void Start()
    {
        relationPage.SetActive(true);
        potion1Page.SetActive(false);
    }

    public void relation(int cust)
    {
        if (cust == 1)
        {
            baldwin++;
            Instantiate(Heart, Bald.transform.position, Bald.transform.rotation, Bald.transform);
        }
        if (cust == 2)
        {
            Cedric++;
            Instantiate(Heart, Ced.transform.position, Ced.transform.rotation, Ced.transform);
        }
        if (cust == 3)
        {
            Isolde++;
            Instantiate(Heart, Iso.transform.position, Iso.transform.rotation, Iso.transform);
        }
        if (cust == 4)
        {
            Rowena++;
            Instantiate(Heart, Row.transform.position, Row.transform.rotation, Row.transform);
        }
    }

    public void R2P1()
    {
        relationPage.SetActive(false);
        potion1Page.SetActive(true);
    }
    public void P12R()
    {
        relationPage.SetActive(true);
        potion1Page.SetActive(false);
    }

}
