using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CuttingManager : MonoBehaviour
{
    private PlayerController player;
    private InputManager inputManager;
    private bool isclose = false;
    public GameObject placement;
    private GameObject item;
    public int cutCount = 0;
    private bool conditions = false;
    public Image progress;

    private void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        progress.fillAmount = 0;
    }

    private void Update()
    {
        if (conditions == true && inputManager.Interact() == true && player.isHolding == false) 
        {
            cutCount++;
        }
        if (isclose == true && inputManager.Interact() == true 
            && player.isHolding == true && conditions == false
            && player.GetType() == ItemSettings.Itemtype.Fresh)
        {
            player.isHolding = false;
            player.FreezePlayer();
            item = Instantiate(player.carry, placement.transform.position, placement.transform.rotation, placement.transform);
            Destroy(player.carry);
            cutCount++;
            conditions = true;
        }
        if (cutCount >= 10 && player.isHolding == false)
        {
            cutCount = 0;
            player.UnFreezePlayer();
            player.isHolding = true;
            player.carry = Instantiate(item, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
            player.SetType(ItemSettings.Itemtype.Cut);
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
