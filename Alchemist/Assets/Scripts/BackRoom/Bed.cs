using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Bed : MonoBehaviour
{
    private WorldTimer timer;
    private InputManager inputManager;
    private PlayerController player;
    public Image fadeIMG;
    private Color fade;
    private bool bedtime = false;
    private float waitTime = 0.0f;
    private int isclose = 0;
    private int total = 2;
    public DataPersistanceManager dataPersistance;

    void Start()
    {
        inputManager = InputManager.Instance;
        dataPersistance = DataPersistanceManager.instance;
        timer = GameObject.FindGameObjectWithTag("Timer").GetComponent<WorldTimer>();
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        fadeIMG.gameObject.SetActive(false);
    }

    private void Update()
    {
        CheckFade(false);
    }

    public void CheckFade(bool check)
    {
        if (player.P2S == true)
        {
            total = 4;
        }
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
        if (fade.a == 0)
        {
            fadeIMG.gameObject.SetActive(false);
        }
        if (fade.a != 0f && bedtime == false && waitTime >= 1.75f)
        {
            fade.a -= 0.01f;
        }
        if ((isclose == total && timer.closed == true && (inputManager.Interact() || inputManager.InteractP2())))
        {
            Debug.Log("Saved");
            dataPersistance.SaveData();
            timer.StartDay();
            fadeIMG.gameObject.SetActive(true);
            bedtime = true;
        }
        if (check == true)
        {
            Debug.Log("Saved");
            dataPersistance.SaveData();
            timer.StartDay();
            fadeIMG.gameObject.SetActive(true);
            bedtime = true;
        }
        fadeIMG.color = fade;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            isclose++;
        }
        if (other.tag == "Player2")
        {
            isclose++;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            isclose--;
        }
        if (other.tag == "Player2")
        {
            isclose--;
        }
    }
}
