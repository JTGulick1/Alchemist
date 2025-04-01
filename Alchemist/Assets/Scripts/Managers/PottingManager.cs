using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PottingManager : MonoBehaviour
{
    private bool stBrew = false;
    private bool isclose = false;
    public bool isclose2 = false;
    private PlayerController player;
    private PlayerController2 player2;
    private bool joined = false;
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

    private void Joined()
    {
        joined = true;
        player2 = GameObject.FindGameObjectWithTag("Player2").GetComponent<PlayerController2>();
    }

    void Update()
    {
        if (player.P2S == true && joined == false)
        {
            Joined();
        }
        if (stBrew == true)
        {
            timer += Time.deltaTime;
            progress.fillAmount = timer / 10;
        }
        if (isclose == true && inputManager.Interact() == true && player.isHolding == true && player.cBrew == true)
        {
            player.cBrew = false;
            stBrew = true;
            brew = Instantiate(player.carry, station.transform.position, station.transform.rotation, station.transform);
            brew.GetComponent<BrewSettings>().enabled = false;
            Destroy(player.carry);
            player.isHolding = false;
        }
        if (timer >= 10.0f && isclose == true && inputManager.Interact() == true && player.isHolding == false)
        {
            timer = 0.0f;
            stBrew = false;
            brew.GetComponent<BrewSettings>().enabled = true;
            player.carry = Instantiate(brew, player.playerHolder.transform.position, player.playerHolder.transform.rotation, player.playerHolder.transform);
            Destroy(brew.gameObject);
            player.carry.GetComponent<BrewSettings>().ChangeToPotion();
            player.isHolding = true;
            progress.fillAmount = 0.0f;
        }
        if (isclose2 == true && inputManager.InteractP2() == true && player2.isHolding == true && player2.cBrew == true)
        {
            player2.cBrew = false;
            stBrew = true;
            brew = Instantiate(player2.carry, station.transform.position, station.transform.rotation, station.transform);
            Destroy(player2.carry);
            player2.isHolding = false;
        }
        if (timer >= 10.0f && isclose2 == true && inputManager.InteractP2() == true && player2.isHolding == false)
        {
            timer = 0.0f;
            stBrew = false;
            player2.carry = Instantiate(brew, player2.playerHolder.transform.position, player2.playerHolder.transform.rotation, player2.playerHolder.transform);
            Destroy(brew.gameObject);
            player2.carry.GetComponent<BrewSettings>().ChangeToPotion();
            player2.isHolding = true;
            progress.fillAmount = 0.0f;
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
