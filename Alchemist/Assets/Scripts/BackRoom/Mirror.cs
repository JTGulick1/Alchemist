using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Mirror : MonoBehaviour
{
    public List<GameObject> vests = new List<GameObject>();
    private bool isclose;
    private PlayerController player;
    private InputManager inputManager;
    public GameObject vestUI;
    void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        vestUI.SetActive(false);

    }

    void Update()
    {
        if (isclose == true && inputManager.Interact() == true)
        {
            Cursor.lockState = CursorLockMode.None;
            vestUI.SetActive(true);
        }
        if (inputManager.Exit()== true)
        {
            Cursor.lockState = CursorLockMode.Locked;
            isclose = false;
            vestUI.SetActive(false);
        }
    }
    public void SetVest(int num)
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
            Cursor.lockState = CursorLockMode.Locked;
            isclose = false;
            vestUI.SetActive(false);
        }
    }
}
