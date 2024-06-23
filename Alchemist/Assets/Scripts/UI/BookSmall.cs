using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BookSmall : MonoBehaviour, IDataPersistance
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

    public GameObject relationPage1;
    public GameObject relationPage2;
    public GameObject potion1Page;
    public GameObject potion2Page;
    public GameObject potion3Page;
    public GameObject potion4Page;
    public GameObject potion5Page;
    public GameObject potion6Page;
    public GameObject potion7Page;
    public GameObject potion8Page;
    public bool Player2Book;
    public PlayerController player1;
    public PlayerController2 player2;

    public int pageNum = 1;

    private void Start()
    {
        relationPage1.SetActive(true);
        player1 = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
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

    public void UpdatePage()
    {
        if (pageNum == 11)
        {
            pageNum = 1;
        }
        if (pageNum < 1)
        {
            pageNum = 1;
        }
        if (pageNum == 1)
        {
            R22R1();
            P82R1();
        }
        if (pageNum == 2)
        {
            R12R2();
            P12R2();
        }
        if (pageNum == 3)
        {
            R22P1();
            P22P1();
        }
        if (pageNum == 4)
        {
            P12P2();
            P32P2();
        }
        if (pageNum == 5)
        {
            P22P3();
            P42P3();
        }
        if (pageNum == 6)
        {
            P32P4();
            P52P4();
        }
        if (pageNum == 7)
        {
            P42P5();
            P62P5();
        }
        if (pageNum == 8)
        {
            P52P6();
            P72P6();
        }
        if (pageNum == 9)
        {
            P62P7();
            P82P7();
        }
        if (pageNum == 10)
        {
            P72P8();
        }
    }

    public void Joined()
    {
        player2 = GameObject.FindGameObjectWithTag("Player2").GetComponent<PlayerController2>();
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

    public void R12R2()
    {
        relationPage1.SetActive(false);
        relationPage2.SetActive(true);
    }
    public void R22R1()
    {
        relationPage1.SetActive(true);
        relationPage2.SetActive(false);
    }

    public void R22P1()
    {
        relationPage2.SetActive(false);
        potion1Page.SetActive(true);
    }
    public void P12R2()
    {
        relationPage2.SetActive(true);
        potion1Page.SetActive(false);
    }

    public void P12P2()
    {
        potion2Page.SetActive(true);
        potion1Page.SetActive(false);
    }
    public void P22P1()
    {
        potion2Page.SetActive(false);
        potion1Page.SetActive(true);
    }

    public void P22P3()
    {
        potion2Page.SetActive(false);
        potion3Page.SetActive(true);
    }
    public void P32P2()
    {
        potion3Page.SetActive(false);
        potion2Page.SetActive(true);
    }
    public void P32P4()
    {
        potion3Page.SetActive(false);
        potion4Page.SetActive(true);
    }
    public void P42P3()
    {
        potion4Page.SetActive(false);
        potion3Page.SetActive(true);
    }

    public void P42P5()
    {
        potion4Page.SetActive(false);
        potion5Page.SetActive(true);
    }
    public void P52P4()
    {
        potion5Page.SetActive(false);
        potion4Page.SetActive(true);
    }

    public void P52P6()
    {
        potion5Page.SetActive(false);
        potion6Page.SetActive(true);
    }
    public void P62P5()
    {
        potion6Page.SetActive(false);
        potion5Page.SetActive(true);
    }

    public void P62P7()
    {
        potion6Page.SetActive(false);
        potion7Page.SetActive(true);
    }
    public void P72P6()
    {
        potion7Page.SetActive(false);
        potion6Page.SetActive(true);
    }

    public void P72P8()
    {
        potion7Page.SetActive(false);
        potion8Page.SetActive(true);
    }
    public void P82P7()
    {
        potion8Page.SetActive(false);
        potion7Page.SetActive(true);
    }

    public void P82R1()
    {
        potion8Page.SetActive(false);
        relationPage1.SetActive(true);
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
