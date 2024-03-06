using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PottingManager : MonoBehaviour
{
    private bool stBrew = false;
    private bool isclose = false;
    private PlayerController player;
    private InputManager inputManager;

    private float timer = 0.0f;

    public Image progress;

    public GameObject brew;
    public GameObject station;

    void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        progress.fillAmount = 0.0f;
    }

    void Update()
    {
        if (stBrew == true)
        {
            timer += Time.deltaTime;
            progress.fillAmount = timer / 10;
        }
        if (isclose == true && inputManager.Interact() == true && player.isHolding == true)
        {
            stBrew = true;
            brew = Instantiate(player.carry, station.transform.position, station.transform.rotation, station.transform);
            Destroy(player.carry);
            player.isHolding = false;
        }
        if (timer >= 10.0f && isclose == true && inputManager.Interact() == true && player.isHolding == false)
        {
            timer = 0.0f;
            stBrew = false;
            player.carry = Instantiate(brew, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
            Destroy(brew.gameObject);
            player.carry.GetComponent<BrewSettings>().ChangeToPotion();
            player.isHolding = true;
            progress.fillAmount = 0.0f;
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
