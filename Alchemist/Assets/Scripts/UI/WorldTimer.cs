using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WorldTimer : MonoBehaviour
{
    [Header("Time")]
    public TMPro.TMP_Text timeShown;
    private int single;
    private int ten;
    private int hrs = 6;
    public float tempTime;
    private bool PM = false;
    private bool day;
    private int custCount = 0;
    public GameObject[] Customers;
    public GameObject CustSpawn;
    private void Start()
    {
        StartDay();
    }

    void Update()
    {
        TimeUpdate();
    }

    void StartDay()
    {
        day = true;
        timeShown.text = "[" + hrs + ":" + ten + single + "]";
        SpawnCust();
    }

    void SpawnCust()
    {
        if (custCount >= 5)
        {
            return;
        }
        custCount += 1;
        Instantiate(Customers[Random.Range(0, Customers.Length)], CustSpawn.transform.position, CustSpawn.transform.rotation);
    }

    void TimeUpdate()
    {
        tempTime += Time.deltaTime;
        if (tempTime >= 10.0f && day == true)
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
            SpawnCust();
        }
        if (hrs == 13)
        {
            PM = true;
            hrs = 1;
            timeShown.text = "[" + hrs + ":" + ten + single + "]";
        }
    }
}
