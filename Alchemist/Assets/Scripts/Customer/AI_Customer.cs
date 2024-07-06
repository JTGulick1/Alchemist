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
    public Image patience;
    private float Ptimer = 100.0f;
    public GameObject currentSpot;

    private GameObject storeDoor;
    private PlayerController player;
    private PlayerController2 player2;
    private bool joined = false;
    private WorldTimer timer;
    private Book book;
    public int custID;
    public AchivementTracker achivement;


    void Start()
    {
        brewing = GameObject.FindGameObjectWithTag("Brewing").GetComponent<BrewingManager>();
        orderSpot = GameObject.FindGameObjectsWithTag("Order Spot");
        timer = GameObject.FindGameObjectWithTag("Timer").GetComponent<WorldTimer>();
        storeDoor = GameObject.FindGameObjectWithTag("Door");
        order = brewing.avaliableBrews[Random.Range(0, brewing.avaliableBrews.Count)];
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        agent = GetComponent<NavMeshAgent>();
        WalkToCounter();
        ordertxt.text = order.brewName;
        ordertxt.gameObject.SetActive(false);
        patience.gameObject.SetActive(false);
        book = player.book;
        achivement = GameObject.FindGameObjectWithTag("Achive").GetComponent<AchivementTracker>();
    }

    private void Update()
    {
        if (timer.stopTime == true)
        {
            return;
        }
        Ptimer -= Time.deltaTime;
        patience.fillAmount = Ptimer / 100;
        if (Ptimer <= 0.0f)
        {
            LeaveStore();
        }
        if (player.P2S == true && joined == false)
        {
            joined = true;
            player2 = GameObject.FindGameObjectWithTag("Player2").GetComponent<PlayerController2>();
        }
        transform.LookAt(FindClosest());
        if (Vector3.Distance(this.gameObject.transform.position , storeDoor.transform.position) <= 1)
        {
            Leave();
        }
    }

    private Transform FindClosest()
    {
        if (joined == false)
        {
            return player.transform;
        }
        if(joined == true)
        {
            float a, b;
            a = Vector3.Distance(player.transform.position, this.gameObject.transform.position);
            b = Vector3.Distance(player2.transform.position, this.gameObject.transform.position);
            if (a > b)
            {
                return player2.transform;
            }
            if (a < b)
            {
                return player.transform;
            }
        }
        return player.transform;
    }

    private void WalkToCounter()
    {
        currentSpot = orderSpot[Random.Range(0, orderSpot.Length)];
        agent.destination = currentSpot.transform.position;
        currentSpot.tag = "Occ";
    }

    public void Served()
    {
        book.relation(custID);
        achivement.pats++;
        if (achivement.pats == 20 || achivement.pats == 50 || 
            achivement.pats == 100 || achivement.pats == 200 ||
            achivement.pats == 400)
        {
            achivement.CheckAchivements();
        }
    }

    public void LeaveStore()
    {
        agent.destination = storeDoor.transform.position;
        currentSpot.tag = "Order Spot";
        timer.CustLeft();
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
            patience.gameObject.SetActive(true);
            player.CustomerOrder(order.physicalForm, this.gameObject.GetComponent<AI_Customer>());
        }
        if (other.tag == "Player2")
        {
            ordertxt.gameObject.SetActive(true);
            patience.gameObject.SetActive(true);
            player2.CustomerOrder(order.physicalForm, this.gameObject.GetComponent<AI_Customer>());
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            ordertxt.gameObject.SetActive(false);
            patience.gameObject.SetActive(false);
            player.ToFarFromCust();
        }
        if (other.tag == "Player2")
        {
            ordertxt.gameObject.SetActive(false);
            patience.gameObject.SetActive(false);
            player2.ToFarFromCust();
        }
    }
}
