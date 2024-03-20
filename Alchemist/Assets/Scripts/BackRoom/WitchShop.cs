using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WitchShop : MonoBehaviour
{
    private bool isclose;
    private InputManager inputManager;
    // Start is called before the first frame update
    void Start()
    {
        inputManager = InputManager.Instance;
    }

    // Update is called once per frame
    void Update()
    {
        if (isclose == true && inputManager.Interact() == true)
        {
            //Open WitchShop
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
