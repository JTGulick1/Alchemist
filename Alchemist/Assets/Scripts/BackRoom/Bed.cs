using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Bed : MonoBehaviour
{
    private WorldTimer timer;
    private bool isclose;
    private InputManager inputManager;
    public Image fadeIMG;
    private Color fade;
    private bool bedtime = false;
    private float waitTime = 0.0f;
    void Start()
    {
        inputManager = InputManager.Instance;
        timer = GameObject.FindGameObjectWithTag("Timer").GetComponent<WorldTimer>();
        fadeIMG.gameObject.SetActive(false);
    }

    private void Update()
    {
        fade = fadeIMG.color;
        if (bedtime == true)
        {
            fade.a += 0.01f;
        }
        if (fade.a >= 0.99f)
        {
            bedtime = false;
        }
        if (fade.a > 0)
        {
            waitTime += Time.deltaTime;
        }
        if (fade.a != 0f && bedtime == false && waitTime >= 1.75f)
        {
            fade.a -= 0.01f;
        }
        if (isclose == true && timer.closed == true && timer.custCount == 0 && inputManager.Interact())
        {
            timer.StartDay();
            fadeIMG.gameObject.SetActive(true);
            bedtime = true;
        }
        if (fade.a == 0)
        {
            fadeIMG.gameObject.SetActive(false);
        }
        fadeIMG.color = fade;
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
