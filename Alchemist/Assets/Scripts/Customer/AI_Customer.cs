using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Unity.AI;

public class AI_Customer : MonoBehaviour
{
    private BrewingManager brewing;
    private GameObject orderSpot;
    private Brews order;
    void Start()
    {
        brewing = GameObject.FindGameObjectWithTag("Brewing").GetComponent<BrewingManager>();
        order = brewing.avaliableBrews[Random.Range(0, brewing.avaliableBrews.Count)];
    }

    void Update()
    {
        
    }
}
