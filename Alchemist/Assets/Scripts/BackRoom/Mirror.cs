using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Mirror : MonoBehaviour
{
    public GameObject vestHolder;
    public List<GameObject> vests = new List<GameObject>();
    public Camera vestCam;
    private bool isclose;
    private PlayerController player;
    private InputManager inputManager;
    void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        vestHolder.SetActive(false);
        vestCam.gameObject.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        if (isclose == true && inputManager.Interact() == true)
        {
            vestCam.gameObject.SetActive(true);
            player.cam.gameObject.SetActive(false);
            player.FreezePlayer();
            vestHolder.SetActive(true);
        }
        if (inputManager.Exit()== true)
        {
            isclose = false;
            vestCam.gameObject.SetActive(false);
            player.cam.gameObject.SetActive(true);
            player.UnFreezePlayer();
            vestHolder.SetActive(false);
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
