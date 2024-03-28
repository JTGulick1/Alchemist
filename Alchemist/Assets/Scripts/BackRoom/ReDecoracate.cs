using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Redecoracate : MonoBehaviour
{
    private bool isclose;
    private InputManager inputManager;
    private PlayerController player;
    public Camera cam;
    private WorldTimer timer;

    public GameObject holding;
    public GameObject UI;
    public GameObject FarAway;
    // Start is called before the first frame update
    void Start()
    {
        inputManager = InputManager.Instance;
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        timer = GameObject.FindGameObjectWithTag("Timer").GetComponent<WorldTimer>();
        UI.SetActive(false);
    }

    // Update is called once per frame
    void Update()
    {
        if (isclose == true && inputManager.Interact() == true)
        {
            UI.SetActive(true);
            Cursor.lockState = CursorLockMode.None;
            timer.stopTime = true;
            if (player.P2S == true)
            {
                player.player1Action();
            }
            player.cam.gameObject.SetActive(false);
            cam.gameObject.SetActive(true);
        }
    }

    public void GrabbedObject(GameObject obj)
    {
        holding = Instantiate(obj, FarAway.transform.position, FarAway.transform.rotation);
    }

    public GameObject PlaceObject()
    {
        return holding;
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
            UI.SetActive(false);
            Cursor.lockState = CursorLockMode.Locked;
            isclose = false;
            timer.stopTime = false;
            if (player.P2S == true)
            {
                player.player1ActionExit();
            }
            cam.gameObject.SetActive(false);
            player.cam.gameObject.SetActive(true);
        }
    }
}
