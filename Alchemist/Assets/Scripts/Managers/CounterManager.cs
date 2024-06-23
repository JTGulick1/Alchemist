using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CounterManager : MonoBehaviour
{
    private PlayerController player;
    private PlayerController2 player2;
    private InputManager inputManager;
    private bool isclose = false;
    private bool isclose2 = false;
    public GameObject placement;
    private GameObject item;

    private void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
    }

    public void Joined()
    {
        player2 = GameObject.FindGameObjectWithTag("Player2").GetComponent<PlayerController2>();
    }

    private void Update()
    {
        if (player.P2S == true && player2 == null)
        {
            Joined();
        }
        if (isclose == true)
        {
            Run(0);
        }
        if (isclose2 == true)
        {
            Run(1);
        }
    }

    private void Run(int num)
    {
        if (num == 0)
        {
            if (isclose == true && inputManager.Interact() == true
                && player.isHolding == true)
            {
                player.isHolding = false;
                item = Instantiate(player.carry, placement.transform.position, placement.transform.rotation, placement.transform);
                Destroy(player.carry);
                return;
            }
            if (player.isHolding == false && inputManager.Interact() == true && isclose == true && item != null)
            {
                player.isHolding = true;
                player.carry = Instantiate(item, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
                Destroy(item);
                return;
            }
        }
        if (num == 1)
        {
            if (isclose2 == true && inputManager.InteractP2() == true
                && player2.isHolding == true)
            {
                player2.isHolding = false;
                player2.FreezePlayer();
                item = Instantiate(player2.carry, placement.transform.position, placement.transform.rotation, placement.transform);
                Destroy(player2.carry);
                return;
            }
            if (player2.isHolding == false && inputManager.InteractP2() == true && isclose2 == true)
            {
                player2.UnFreezePlayer();
                player2.isHolding = true;
                player2.carry = Instantiate(item, player2.playerHolder.transform.position, player2.playerHolder.transform.rotation, player2.playerHolder.transform);
                Destroy(item);
                return;
            }
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            isclose = true;
        }
        if (other.tag == "Player2")
        {
            isclose2 = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            isclose = false;
        }
        if (other.tag == "Player2")
        {
            isclose2 = false;
        }
    }
}
