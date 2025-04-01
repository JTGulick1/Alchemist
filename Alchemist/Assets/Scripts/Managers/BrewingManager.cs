using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class BrewingManager : MonoBehaviour
{
    private int cap = 3;
    public List<ItemSettings> items = new List<ItemSettings>();
    public List<Brews> avaliableBrews = new List<Brews>();

    public GameObject pot;
    public GameObject poop;
    private bool isclose = false;
    private bool isclose2 = false;
    private PlayerController player;
    private PlayerController2 player2;
    private bool p2A = false;
    private InputManager inputManager;

    public Image progress;

    private float timer = 0.0f;

    private void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        progress.fillAmount = 0.0f;
    }



    private void Update()
    {
        if (player.P2S == true && p2A == false)
        {
            p2A = true;
            player2 = GameObject.FindGameObjectWithTag("Player2").GetComponent<PlayerController2>();
        }
        if (items[2] != null)
        {
            timer += Time.deltaTime;
            progress.fillAmount = timer / 10;
        }
        if (timer >= 10.0f && isclose == true && items[2] != null && inputManager.Interact() == true && player.isHolding == false && items[0] != null)
        {
            timer = 0;
            Brew(0);
        }
        if (timer >= 10.0f && isclose2 == true && items[2] != null && inputManager.InteractP2() == true && player2.isHolding == false && items[0] != null)
        {
            timer = 0;
            Brew(1);
        }
        if (isclose == true && items[2] == null &&
            player.isHolding == true && inputManager.Interact() == true && player.cBrew == false && player.carry.GetComponent<ItemSettings>() == true)
        {
            GameObject temp;
            temp = Instantiate(player.carry, pot.transform.position, pot.transform.rotation, pot.transform);
            PlaceIng(temp);
            temp.tag = "Ingredient";
            player.isHolding = false;
            Destroy(player.carry);
        }
        if (isclose2 == true && items[2] == null &&
            player2.isHolding == true && inputManager.InteractP2() == true && player2.cBrew == false)
        {
            GameObject temp;
            temp = Instantiate(player2.carry, pot.transform.position, pot.transform.rotation, pot.transform);
            PlaceIng(temp);
            temp.tag = "Ingredient";
            player2.isHolding = false;
            Destroy(player2.carry);
        }
    }

    private void PlaceIng(GameObject temp)
    {
        if (items[0] == null)
        {
            items[0] = temp.GetComponent<ItemSettings>();
            temp.GetComponent<ItemSettings>().enabled = false;
            return;
        }
        if (items[1] == null)
        {
            items[1] = temp.GetComponent<ItemSettings>();
            temp.GetComponent<ItemSettings>().enabled = false;
            return;
        }
        if (items[2] == null)
        {
            items[2] = temp.GetComponent<ItemSettings>();
            temp.GetComponent<ItemSettings>().enabled = false;
            return;
        }
    }

    private void Brew(int num)
    {
        progress.fillAmount = 0.0f;
        DestroyIngredients();
        if (num == 0)
        {
            player.isHolding = true;
            for (int i = 0; i < avaliableBrews.Count; i++)
            {
                if (avaliableBrews[i].Ing1.GetComponent<ItemSettings>().itemtype == items[0].itemtype &&
                    avaliableBrews[i].Ing2.GetComponent<ItemSettings>().itemtype == items[1].itemtype &&
                    avaliableBrews[i].Ing3.GetComponent<ItemSettings>().itemtype == items[2].itemtype &&
                    avaliableBrews[i].Ing1.GetComponent<ItemSettings>().ingName == items[0].ingName &&
                    avaliableBrews[i].Ing2.GetComponent<ItemSettings>().ingName == items[1].ingName &&
                    avaliableBrews[i].Ing3.GetComponent<ItemSettings>().ingName == items[2].ingName)
                {
                    player.carry = Instantiate(avaliableBrews[i].physicalForm, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
                    player.carry.GetComponent<BrewSettings>().ChangeToBrew();
                    player.cBrew = true;
                    return;
                }
            }
            player.carry = Instantiate(poop, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
            player.carry.GetComponent<BrewSettings>().ChangeToBrew();
            player.cBrew = true;
        }
        if (num == 1)
        {
            player2.isHolding = true;
            for (int i = 0; i < avaliableBrews.Count; i++)
            {
                if (avaliableBrews[i].Ing1.GetComponent<ItemSettings>().itemtype == items[0].itemtype &&
                    avaliableBrews[i].Ing2.GetComponent<ItemSettings>().itemtype == items[1].itemtype &&
                    avaliableBrews[i].Ing3.GetComponent<ItemSettings>().itemtype == items[2].itemtype &&
                    avaliableBrews[i].Ing1.GetComponent<ItemSettings>().ingName == items[0].ingName &&
                    avaliableBrews[i].Ing2.GetComponent<ItemSettings>().ingName == items[1].ingName &&
                    avaliableBrews[i].Ing3.GetComponent<ItemSettings>().ingName == items[2].ingName)
                {
                    player2.carry = Instantiate(avaliableBrews[i].physicalForm, player2.playerHolder.transform.position, player2.playerHolder.transform.rotation, player2.playerHolder.transform);
                    player2.carry.GetComponent<BrewSettings>().ChangeToBrew();
                    player2.cBrew = true;
                    return;
                }
            }
            player2.carry = Instantiate(poop, player2.playerHolder.transform.position, player2.playerHolder.transform.rotation, player2.playerHolder.transform);
            player2.carry.GetComponent<BrewSettings>().ChangeToBrew();
            player2.cBrew = true;
        }
    }

    private void DestroyIngredients()
    {
        foreach (GameObject item in GameObject.FindGameObjectsWithTag("Ingredient"))
        {
            Destroy(item);
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
