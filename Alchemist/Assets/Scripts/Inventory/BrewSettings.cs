using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrewSettings : MonoBehaviour
{
    public string title = "name";
    public string temp = "";
    public Sprite image;
    public GameObject C;
    public GameObject B;
    public int price = 15;
    public bool isPot;
    public int saveInt;
    private bool playerIsClose = false;
    private bool player2IsClose = false;
    private InputManager inputManager;
    private PlayerController player1;
    private PlayerController2 player2;
    public Rigidbody rb;
    public BoxCollider box;
    private int randomPull;
    public GameObject brokenPotion;
    private void Start()
    {
        temp = title;
        inputManager = InputManager.Instance;
        rb = GetComponent<Rigidbody>();
        box = GetComponent<BoxCollider>();
    }

    public void ChangeToBrew()
    {
        C.SetActive(true);
        B.SetActive(false);
        temp += " Brew";
    }

    public void ChangeToPotion()
    {
        isPot = true;
        C.SetActive(false);
        B.SetActive(true);
        temp = title;
    }

    private void Update()
    {
        if (playerIsClose == true && inputManager.Interact())
        {
            player1.PickUpObject(this.gameObject);
        }
        if (player2IsClose == true && inputManager.InteractP2())
        {
            player2.PickUpObject(this.gameObject);
        }
    }
    public void Grounded(Vector3 vector3)
    {
        rb.isKinematic = false;
        box.enabled = true;
        rb.AddForce(vector3, ForceMode.Impulse);
    }

    public void Held()
    {
        box.enabled = false;
        rb.isKinematic = true;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            playerIsClose = true;
            player1 = other.GetComponent<PlayerController>();
        }
        if (other.tag == "Player2")
        {
            player2IsClose = true;
            player2 = other.GetComponent<PlayerController2>();
        }
        if (other.tag == "Ground")
        {
            randomPull = Random.Range(0, 100);
            if (randomPull < 24)
            {
                BreakPotion();
            }
        }
    }

    private void BreakPotion()
    {
        Instantiate(brokenPotion, new Vector3(this.transform.position.x, -0.42f, this.transform.position.z), brokenPotion.transform.rotation);
        Destroy(this.gameObject);
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            playerIsClose = false;
        }
        if (other.tag == "Player2")
        {
            player2IsClose = false;
        }
    }
}
