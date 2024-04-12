using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WorldTimer : MonoBehaviour, IDataPersistance
{
    [Header("Time")]
    public TMPro.TMP_Text timeShown;
    public TMPro.TMP_Text closedtxt;
    public TMPro.TMP_Text dayOfWeek;
    private int single;
    private int ten;
    private int hrs = 6;
    public float tempTime;
    private bool PM = true;
    public bool closed = false;
    private int day = 0;
    private int totaldays = 0;
    public int custCount = 0;
    public GameObject[] Customers;
    public GameObject CustSpawn;
    public bool stopTime = false;
    public Bed bed;
    private void Start()
    {
        StartDay();
    }

    void Update()
    {
        TimeUpdate();
    }

    public void StartDay()
    {
        hrs = 6;
        ten = 0;
        timeShown.text = "[" + hrs + ":" + ten + single + "]";
        closedtxt.gameObject.SetActive(false);
        closed = false;
        SpawnCust();
        if (PM == true)
        {
            UpdateDay();
            PM = false;
        }
    }
    public void StartDayLate()
    {
        hrs = 9;
        ten = 0;
        timeShown.text = "[" + hrs + ":" + ten + single + "]";
        closedtxt.gameObject.SetActive(false);
        closed = false;
        SpawnCust();
        UpdateDay();
        PM = false;
    }

    public void LoadData(GameData data)
    {
        day = data.currentday;
        totaldays = data.dayCount;
    }

    public void SaveData(ref GameData data)
    {
        data.currentday = day;
        data.dayCount = totaldays;
    }


    void TimeUpdate()
    {
        if (stopTime == true)
        {
            return;
        }
        tempTime += Time.deltaTime;
        if (tempTime >= 10.0f)
        {
            ten++;
            tempTime = 0.0f;
            timeShown.text = "[" + hrs + ":" + ten + single + "]";
        }
        if (ten == 6)
        {
            ten = 0;
            hrs++;
            timeShown.text = "[" + hrs + ":" + ten + single + "]";
            if (closed == false)
            {
                SpawnCust();
            }
        }
        if (hrs == 13)
        {
            PM = true;
            hrs = 1;
            timeShown.text = "[" + hrs + ":" + ten + single + "]";
        }
        if (hrs == 8 && PM == true)
        {
            closed = true;
            closedtxt.gameObject.SetActive(true);
        }
        if (hrs == 13 && PM == true)
        {
            hrs = 1;
            PM = false;
            timeShown.text = "[" + hrs + ":" + ten + single + "]";
            UpdateDay();
        }
        if (hrs == 2 && PM == false)
        {
            bed.CheckFade(true);
            UpdateDay();
            StartDayLate();
        }
    }

    public void UpdateDay()
    {
        day++;
        totaldays++;
        if (day == 8)
        {
            day = 1;
        }
        if (day == 1)
        {
            dayOfWeek.text = "Monday";
        }
        if (day == 2)
        {
            dayOfWeek.text = "Tuesday";
        }
        if (day == 3)
        {
            dayOfWeek.text = "Wednesday";
        }
        if (day == 4)
        {
            dayOfWeek.text = "Thursday";
        }
        if (day == 5)
        {
            dayOfWeek.text = "Friday";
        }
        if (day == 6)
        {
            dayOfWeek.text = "Saturday";
        }
        if (day == 7)
        {
            dayOfWeek.text = "Sunday";
        }
    }

    // Customers Infomation Systems

    void SpawnCust()
    {
        if (custCount >= 5)
        {
            return;
        }
        custCount += 1;
        Instantiate(Customers[Random.Range(0, Customers.Length)], CustSpawn.transform.position, CustSpawn.transform.rotation);
    }

    public void CustLeft()
    {
        custCount -= 1;
    }
}
