using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CuttingManager : MonoBehaviour
{
    private PlayerController player;
    private PlayerController2 player2;
    private InputManager inputManager;
    private bool isclose = false;
    private bool isclose2 = false;
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
            if (conditions == true && inputManager.Interact() == true && player.isHolding == false)
            {
                cutCount++;
                progress.fillAmount += 0.10f;
            }
            if (isclose == true && inputManager.Interact() == true
                && player.isHolding == true && conditions == false
                && player.GetType() == ItemSettings.Itemtype.Fresh)
            {
                player.isHolding = false;
                item = Instantiate(player.carry, placement.transform.position, placement.transform.rotation, placement.transform);
                Destroy(player.carry);
                cutCount++;
                conditions = true;
                progress.fillAmount += 0.10f;
            }
            if (cutCount >= 10 && player.isHolding == false)
            {
                progress.fillAmount = 0;
                cutCount = 0;
                player.isHolding = true;
                player.carry = Instantiate(item, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
                player.SetType(ItemSettings.Itemtype.Cut);
                Destroy(item);
                conditions = false;
            }
        }
        if (num == 1)
        {
            if (conditions == true && inputManager.InteractP2() == true && player2.isHolding == false)
            {
                cutCount++;
                progress.fillAmount += 0.10f;
            }
            if (isclose2 == true && inputManager.InteractP2() == true
                && player2.isHolding == true && conditions == false
                && player2.GetType() == ItemSettings.Itemtype.Fresh)
            {
                player2.isHolding = false;
                player2.FreezePlayer();
                item = Instantiate(player2.carry, placement.transform.position, placement.transform.rotation, placement.transform);
                Destroy(player2.carry);
                cutCount++;
                conditions = true;
                progress.fillAmount += 0.10f;
            }
            if (cutCount >= 10 && player2.isHolding == false)
            {
                progress.fillAmount = 0;
                cutCount = 0;
                player2.UnFreezePlayer();
                player2.isHolding = true;
                player2.carry = Instantiate(item, player2.playerHolder.transform.position, player2.playerHolder.transform.rotation, player2.playerHolder.transform);
                player2.SetType(ItemSettings.Itemtype.Cut);
                Destroy(item);
                conditions = false;
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
