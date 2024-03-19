using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bed : MonoBehaviour
{
    private WorldTimer timer;
    private bool isclose;
    private InputManager inputManager;
    void Start()
    {
        inputManager = InputManager.Instance;
        timer = GameObject.FindGameObjectWithTag("Timer").GetComponent<WorldTimer>();
    }

    private void Update()
    {
        if (isclose == true && timer.closed == true && timer.custCount == 0 && inputManager.Interact())
        {
            timer.StartDay();
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
