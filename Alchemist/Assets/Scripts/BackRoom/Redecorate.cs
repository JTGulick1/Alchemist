using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Redecorate : MonoBehaviour, IDataPersistance
{
    private bool isclose;
    private InputManager inputManager;
    private PlayerController player;
    public Camera cam;
    private WorldTimer timer;

    public GameObject holding;
    public GameObject UI;
    public GameObject FarAway;
    public int holdingNum;
    public List<int> reDec = new List<int>();
    public GameObject[] reDecObj;

    // Prefabs
    public GameObject brewingCooker;
    public GameObject counter;
    public GameObject cutting;
    public GameObject inventory;
    public GameObject mudding;
    public GameObject potting;

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

    public void GrabbedObject(GameObject obj, int num, int station)
    {
        reDec[station] = 0;
        holding = Instantiate(obj, FarAway.transform.position, FarAway.transform.rotation);
        holdingNum = num;
    }

    public GameObject PlaceObject()
    {
        return holding;
    }

    public int getNum(int station)
    {
        reDec[station] = holdingNum;
        return holdingNum;
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

    private void ReplacePrefabs()
    {
        for (int i = 0; i < reDecObj.Length; i++)
        {
            if (reDecObj[i].GetComponent<RedecorateButton>().objHere == true)
            {
                reDecObj[i].GetComponent<RedecorateButton>().objHere = false;
                Destroy(reDecObj[i].GetComponent<RedecorateButton>().obj);
            }
        }

        for (int i = 0; i < reDec.Count; i++)
        {
            if (reDec[i] == 0)
            {
                continue;
            }
            if (reDec[i] == 1)
            {
                reDecObj[i].GetComponent<RedecorateButton>().obj = Instantiate(brewingCooker, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.position, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.rotation);
            }
            if (reDec[i] == 2)
            {
                reDecObj[i].GetComponent<RedecorateButton>().obj = Instantiate(counter, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.position, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.rotation);
            }
            if (reDec[i] == 3)
            {
                reDecObj[i].GetComponent<RedecorateButton>().obj = Instantiate(cutting, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.position, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.rotation);
            }
            if (reDec[i] == 4)
            {
                reDecObj[i].GetComponent<RedecorateButton>().obj = Instantiate(inventory, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.position, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.rotation);
            }
            if (reDec[i] == 5)
            {
                reDecObj[i].GetComponent<RedecorateButton>().obj = Instantiate(mudding, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.position, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.rotation);
            }
            if (reDec[i] == 6)
            {
                reDecObj[i].GetComponent<RedecorateButton>().obj = Instantiate(potting, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.position, reDecObj[i].GetComponent<RedecorateButton>().spawn.transform.rotation);
            }
            reDecObj[i].GetComponent<RedecorateButton>().objHere = true;
        }
    }

    public void LoadData(GameData data)
    {
        reDec = data.reDec;
        for (int i = 0; i < reDecObj.Length; i++)
        {
            reDecObj[i].GetComponent<RedecorateButton>().itemNum = reDec[i];
        }
        ReplacePrefabs();
    }

    public void SaveData(ref GameData data)
    {
        data.reDec = reDec;
    }

}
