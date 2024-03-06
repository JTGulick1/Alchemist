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
    private PlayerController player;
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
        if (items[2] != null)
        {
            timer += Time.deltaTime;
            progress.fillAmount = timer / 10;
        }
        if (timer >= 10.0f && isclose == true && items[2] != null && inputManager.Interact() == true && player.isHolding == false && items[0] != null)
        {
            timer = 0;
            Brew();
        }
        if (isclose == true && items[2] == null &&
            player.isHolding == true && inputManager.Interact() == true)
        {
            GameObject temp;
            temp = Instantiate(player.carry, pot.transform.position, pot.transform.rotation, pot.transform);
            PlaceIng(temp);
            temp.tag = "Ingredient";
            player.isHolding = false;
            Destroy(player.carry);
        }
    }

    private void PlaceIng(GameObject temp)
    {
        if (items[0] == null)
        {
            items[0] = temp.GetComponent<ItemSettings>();
            return;
        }
        if (items[1] == null)
        {
            items[1] = temp.GetComponent<ItemSettings>();
            return;
        }
        if (items[2] == null)
        {
            items[2] = temp.GetComponent<ItemSettings>();
            return;
        }
    }

    private void Brew()
    {
        progress.fillAmount = 0.0f;
        DestroyIngredients();
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
                return;
            }
        }
        player.carry = Instantiate(poop, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
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
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            isclose = false;
        }
    }
}
