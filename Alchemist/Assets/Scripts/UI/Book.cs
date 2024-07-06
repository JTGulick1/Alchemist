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

    public AchivementTracker achivement;

    private void Start()
    {
        relationPage.SetActive(true);
        achivement = GameObject.FindGameObjectWithTag("Achive").GetComponent<AchivementTracker>();
    }

    public void OpenedSave()
    {
        for (int i = 0; i < baldwin; i++)
        {
            Instantiate(Heart, Bald.transform.position, Bald.transform.rotation, Bald.transform);
        }
        for (int i = 0; i < Cedric; i++)
        {
            Instantiate(Heart, Ced.transform.position, Ced.transform.rotation, Ced.transform);
        }
        for (int i = 0; i < Isolde; i++)
        {
            Instantiate(Heart, Iso.transform.position, Iso.transform.rotation, Iso.transform);
        }
        for (int i = 0; i < Rowena; i++)
        {
            Instantiate(Heart, Row.transform.position, Row.transform.rotation, Row.transform);
        }
    }

    public void relation(int cust)
    {
        if (cust == 1 && baldwin <= 50)
        {
            baldwin++;
            Instantiate(Heart, Bald.transform.position, Bald.transform.rotation, Bald.transform);
            if (baldwin == 50)
            {
                achivement.maxR++;
                achivement.bals = true;
                achivement.CheckAchivements();
            }
        }
        if (cust == 2 && Cedric <= 50)
        {
            Cedric++;
            Instantiate(Heart, Ced.transform.position, Ced.transform.rotation, Ced.transform);
            if (Cedric == 50)
            {
                achivement.maxR++;
                achivement.CheckAchivements();
            }
        }
        if (cust == 3 && Isolde <= 50)
        {
            Isolde++;
            Instantiate(Heart, Iso.transform.position, Iso.transform.rotation, Iso.transform);
            if (Isolde == 50)
            {
                achivement.maxR++;
                achivement.CheckAchivements();
            }
        }
        if (cust == 4 && Rowena <= 50)
        {
            Rowena++;
            Instantiate(Heart, Row.transform.position, Row.transform.rotation, Row.transform);
            if (Rowena == 50)
            {
                achivement.maxR++;
                achivement.CheckAchivements();
            }
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
