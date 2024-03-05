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
        if (items.Count == 3)
        {
            timer += Time.deltaTime;
            progress.fillAmount = timer / 10;
        }
        if (timer >= 10.0f && isclose == true && items.Count == 3 && inputManager.Interact() == true && player.isHolding == false)
        {
            timer = 0;
            Brew();
        }
        if (isclose == true && items.Count != cap &&
            player.isHolding == true && inputManager.Interact() == true)
        {
            GameObject temp;
            temp = Instantiate(player.carry, pot.transform.position, pot.transform.rotation, pot.transform);
            items.Add(temp.GetComponent<ItemSettings>());
            player.isHolding = false;
            Destroy(player.carry);
        }
    }

    private void Brew()
    {
        for (int i = 0; i < avaliableBrews.Count; i++)
        {
            if (avaliableBrews[i].Ing1.GetComponent<ItemSettings>().itemtype == items[0].itemtype &&
                avaliableBrews[i].Ing2.GetComponent<ItemSettings>().itemtype == items[1].itemtype &&
                avaliableBrews[i].Ing3.GetComponent<ItemSettings>().itemtype == items[2].itemtype &&
                avaliableBrews[i].Ing1.GetComponent<ItemSettings>().ingName == items[0].ingName &&
                avaliableBrews[i].Ing2.GetComponent<ItemSettings>().ingName == items[1].ingName &&
                avaliableBrews[i].Ing3.GetComponent<ItemSettings>().ingName == items[2].ingName)
            {
                Destroy(items[0]);
                Destroy(items[1]);
                Destroy(items[2]);
                player.carry = Instantiate(avaliableBrews[i].physicalForm, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
                player.isHolding = true;
                return;
            }
        }
        player.isHolding = true;
        player.carry = Instantiate(poop, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
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
