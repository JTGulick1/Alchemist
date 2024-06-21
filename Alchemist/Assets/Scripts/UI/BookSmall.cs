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

    public GameObject b1;
    public GameObject b2;
    public GameObject b3;
    public GameObject b4;
    public GameObject b5;
    public GameObject b6;
    public GameObject b7;
    public GameObject b8;
    public GameObject b9;
    public GameObject b10;

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
        if (Player2Book)
        {
            player2.selected(b2);
        }
        relationPage1.SetActive(false);
        relationPage2.SetActive(true);
    }
    public void R22R1()
    {
        if (Player2Book)
        {
            player2.selected(b1);
        }
        relationPage1.SetActive(true);
        relationPage2.SetActive(false);
    }

    public void R22P1()
    {
        if (Player2Book)
        {
            player2.selected(b3);
        }
        relationPage2.SetActive(false);
        potion1Page.SetActive(true);
    }
    public void P12R2()
    {
        if (Player2Book)
        {
            player2.selected(b2);
        }
        relationPage2.SetActive(true);
        potion1Page.SetActive(false);
    }

    public void P12P2()
    {
        if (Player2Book)
        {
            player2.selected(b4);
        }
        potion2Page.SetActive(true);
        potion1Page.SetActive(false);
    }
    public void P22P1()
    {
        if (Player2Book)
        {
            player2.selected(b3);
        }
        potion2Page.SetActive(false);
        potion1Page.SetActive(true);
    }

    public void P22P3()
    {
        if (Player2Book)
        {
            player2.selected(b5);
        }
        potion2Page.SetActive(false);
        potion3Page.SetActive(true);
    }
    public void P32P2()
    {
        if (Player2Book)
        {
            player2.selected(b4);
        }
        potion3Page.SetActive(false);
        potion2Page.SetActive(true);
    }
    public void P32P4()
    {
        if (Player2Book)
        {
            player2.selected(b6);
        }
        potion3Page.SetActive(false);
        potion4Page.SetActive(true);
    }
    public void P42P3()
    {
        if (Player2Book)
        {
            player2.selected(b5);
        }
        potion4Page.SetActive(false);
        potion3Page.SetActive(true);
    }

    public void P42P5()
    {
        if (Player2Book)
        {
            player2.selected(b7);
        }
        potion4Page.SetActive(false);
        potion5Page.SetActive(true);
    }
    public void P52P4()
    {
        if (Player2Book)
        {
            player2.selected(b6);
        }
        potion5Page.SetActive(false);
        potion4Page.SetActive(true);
    }

    public void P52P6()
    {
        if (Player2Book)
        {
            player2.selected(b8);
        }
        potion5Page.SetActive(false);
        potion6Page.SetActive(true);
    }
    public void P62P5()
    {
        if (Player2Book)
        {
            player2.selected(b7);
        }
        potion6Page.SetActive(false);
        potion5Page.SetActive(true);
    }

    public void P62P7()
    {
        if (Player2Book)
        {
            player2.selected(b9);
        }
        potion6Page.SetActive(false);
        potion7Page.SetActive(true);
    }
    public void P72P6()
    {
        if (Player2Book)
        {
            player2.selected(b8);
        }
        potion7Page.SetActive(false);
        potion6Page.SetActive(true);
    }

    public void P72P8()
    {
        if (Player2Book)
        {
            player2.selected(b10);
        }
        potion7Page.SetActive(false);
        potion8Page.SetActive(true);
    }
    public void P82P7()
    {
        if (Player2Book)
        {
            player2.selected(b9);
        }
        potion8Page.SetActive(false);
        potion7Page.SetActive(true);
    }

    public void P82R1()
    {
        if (Player2Book)
        {
            player2.selected(b1);
        }
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
