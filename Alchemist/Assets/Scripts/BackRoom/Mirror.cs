using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Mirror : MonoBehaviour
{
    public List<GameObject> vests = new List<GameObject>();
    public List<bool> achive = new List<bool>();
    private bool isclose;
    private bool isclose2;
    private PlayerController player;
    private PlayerController2 player2;
    private InputManager inputManager;
    public GameObject vestUI;
    public GameObject vestUIp1;
    public GameObject vestUIp2;
    public GameObject First;
    void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        vestUI.SetActive(false);
        vestUIp1.SetActive(false);
        vestUIp2.SetActive(false);

    }

    private void Joined()
    {
        player2 = GameObject.FindGameObjectWithTag("Player2").GetComponent<PlayerController2>();
    }

    void Update()
    {
        if (player2 == null && player.P2S == true)
        {
            Joined();
        }
        if (isclose == true && inputManager.Interact() == true && player.P2S == false)
        {
            Cursor.lockState = CursorLockMode.None;
            vestUI.SetActive(true);
        }
        if (isclose == true && inputManager.Interact() == true && player.P2S == true)
        {
            Cursor.lockState = CursorLockMode.None;
            vestUIp1.SetActive(true);
        }
        if (isclose2 == true && inputManager.InteractP2() == true && player.P2S == true)
        {
            vestUIp2.SetActive(true);
            player2.selected(First);
        }
        if (inputManager.Exit() == true)
        {
            Cursor.lockState = CursorLockMode.Locked;
            isclose = false;
            vestUI.SetActive(false);
        }
    }
    public void SetVest(int num)
    {
        if (isclose == true && achive[num] == true)
        {
            if (player.vest == null)
            {
                player.vest = Instantiate(vests[num], player.vestHolder.transform.position, player.vestHolder.transform.rotation, player.vestHolder.transform);
            }
            if (player != null)
            {
                Destroy(player.vest);
                player.vest = Instantiate(vests[num], player.vestHolder.transform.position, player.vestHolder.transform.rotation, player.vestHolder.transform);
            }
        }
        if (isclose2 == true && achive[num] == true)
        {
            if (player2.vest == null)
            {
                player2.vest = Instantiate(vests[num], player2.vestHolder.transform.position, player2.vestHolder.transform.rotation, player2.vestHolder.transform);
            }
            if (player2 != null)
            {
                Destroy(player2.vest);
                player2.vest = Instantiate(vests[num], player2.vestHolder.transform.position, player2.vestHolder.transform.rotation, player2.vestHolder.transform);
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
            Cursor.lockState = CursorLockMode.Locked;
            isclose = false;
            vestUI.SetActive(false);
            vestUIp1.SetActive(false);
        }
        if (other.tag == "Player2")
        {
            isclose2 = false;
            vestUIp2.SetActive(false);
        }
    }
}
