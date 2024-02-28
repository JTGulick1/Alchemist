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
        }
        if (hrs == 13)
        {
            PM = true;
            hrs = 1;
            timeShown.text = "[" + hrs + ":" + ten + single + "]";
        }
    }
}
