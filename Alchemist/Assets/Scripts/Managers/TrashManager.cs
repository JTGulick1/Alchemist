using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TrashManager : MonoBehaviour
{

    private PlayerController player;
    private InputManager inputManager;

    private bool isclose = false;

    private Currency currency;

    // Start is called before the first frame update
    void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
    }

    // Update is called once per frame
    void Update()
    {
        if (isclose == true && inputManager.Interact() == true && player.isHolding == true)
        {
            player.isHolding = false;
            Destroy(player.carry);
            currency.GetGold(3);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            isclose = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            isclose = false;
        }
    }
}