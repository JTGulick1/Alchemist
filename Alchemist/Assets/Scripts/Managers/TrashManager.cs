using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrashManager : MonoBehaviour
{

    private PlayerController player;
    private PlayerController2 player2;
    private InputManager inputManager;

    private bool isclose = false;
    private bool isclose2 = false;
    private bool joined = false;

    private Currency currency;

    void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
    }

    void Update()
    {
        if (player.P2S == true && joined == false)
        {
            joined = true;
            player2 = GameObject.FindGameObjectWithTag("Player2").GetComponent<PlayerController2>();
        }
        if (isclose == true && inputManager.Interact() == true && player.isHolding == true)
        {
            player.isHolding = false;
            Destroy(player.carry);
            currency.GetGold(3);
        }
        if (isclose2 == true && inputManager.InteractP2() == true && player2.isHolding == true)
        {
            player2.isHolding = false;
            Destroy(player2.carry);
            currency.GetGold(3);
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
