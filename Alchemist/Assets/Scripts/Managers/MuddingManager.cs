using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MuddingManager : MonoBehaviour
{
    private PlayerController player;
    private InputManager inputManager;
    private bool isclose = false;
    public GameObject placement;
    private GameObject item;
    public int cutCount = 0;
    private bool conditions = false;

    private void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
    }

    private void Update()
    {
        if (conditions == true && inputManager.Interact() == true)
        {
            cutCount++;
        }
        if (isclose == true && inputManager.Interact() == true
            && player.isHolding == true && conditions == false
            && player.GetType() == ItemSettings.Itemtype.Cut)
        {
            player.isHolding = false;
            player.FreezePlayer();
            item = Instantiate(player.carry, placement.transform.position, placement.transform.rotation, placement.transform);
            Destroy(player.carry);
            cutCount++;
            conditions = true;
        }
        if (cutCount >= 10)
        {
            cutCount = 0;
            player.UnFreezePlayer();
            player.isHolding = true;
            player.carry = Instantiate(item, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
            player.SetType(ItemSettings.Itemtype.Molded);
            Destroy(item);
            conditions = false;
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
