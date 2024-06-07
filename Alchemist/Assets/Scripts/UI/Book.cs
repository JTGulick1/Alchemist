using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Book : MonoBehaviour, IDataPersistance
{
    public int baldwin = 0;
    public int Cedric = 0;
    public int Isolde = 0;
    public int Rowena = 0;
    public GameObject Heart;

    public GameObject Bald;
    public GameObject Ced;
    public GameObject Iso;
    public GameObject Row;

    public GameObject relationPage;
    public GameObject potion1Page;
    public GameObject potion2Page;
    public GameObject potion3Page;

    private void Start()
    {
        relationPage.SetActive(true);
    }

    public void OpenedSave()
    {
        for (int i = 0; i < baldwin; i++)
        {
            relation(1);
        }
        for (int i = 0; i < Cedric; i++)
        {
            relation(2);
        }
        for (int i = 0; i < Isolde; i++)
        {
            relation(3);
        }
        for (int i = 0; i < Rowena; i++)
        {
            relation(4);
        }
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
    public void P32R()
    {
        relationPage.SetActive(true);
        potion3Page.SetActive(false);
    }
    public void P12P2()
    {
        potion2Page.SetActive(true);
        potion1Page.SetActive(false);
    }
    public void P22P3()
    {
        potion2Page.SetActive(false);
        potion3Page.SetActive(true);
    }
    public void P22P1()
    {
        potion2Page.SetActive(false);
        potion1Page.SetActive(true);
    }
    public void P32P2()
    {
        potion3Page.SetActive(false);
        potion2Page.SetActive(true);
    }

    public void LoadData(GameData data)
    {
        baldwin = data.Baldwin;
        Cedric = data.Cedric;
        Isolde = data.Isolde;
        Rowena = data.Rowena;
        OpenedSave();
    }

    public void SaveData(ref GameData data)
    {
        data.Baldwin = baldwin;
        data.Cedric = Cedric;
        data.Isolde = Isolde;
        data.Rowena = Rowena;
    }
}
