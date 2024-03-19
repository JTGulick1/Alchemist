using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;
using UnityEngine.UI;

public class AI_Customer : MonoBehaviour
{
    private BrewingManager brewing;
    private Brews order;
    private NavMeshAgent agent;

    private GameObject[] orderSpot;
    public TMPro.TMP_Text ordertxt;

    private GameObject storeDoor;
    private PlayerController player;

    void Start()
    {
        brewing = GameObject.FindGameObjectWithTag("Brewing").GetComponent<BrewingManager>();
        orderSpot = GameObject.FindGameObjectsWithTag("Order Spot");
        storeDoor = GameObject.FindGameObjectWithTag("Door");
        order = brewing.avaliableBrews[Random.Range(0, brewing.avaliableBrews.Count)];
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        agent = GetComponent<NavMeshAgent>();
        WalkToCounter();
        ordertxt.gameObject.SetActive(false);
    }

    private void Update()
    {
        transform.LookAt(player.transform);

    }
    private void WalkToCounter()
    {
        agent.destination = orderSpot[Random.Range(0, orderSpot.Length)].transform.position;
    }

    public void LeaveStore()
    {
        agent.destination = storeDoor.transform.position;
    }

    public void Leave()
    {
        Destroy(this.gameObject);
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            ordertxt.gameObject.SetActive(true);
            player.CustomerOrder(order.physicalForm, this.gameObject.GetComponent<AI_Customer>());
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            ordertxt.gameObject.SetActive(false);
        }
    }
}
