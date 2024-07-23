using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemSettings : MonoBehaviour
{
    public string ingName = "";
    public enum Itemtype
    {
        Fresh,
        Cut,
        Molded
    }
    public Itemtype itemtype;
    private bool playerIsClose = false;
    private bool player2IsClose = false;
    private InputManager inputManager;
    private PlayerController player1;
    private PlayerController2 player2;
    public Rigidbody rb;
    public BoxCollider box;
    private void Start()
    {
        inputManager = InputManager.Instance;
        rb = GetComponent<Rigidbody>();
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
        rb.AddForce(vector3 * 10, ForceMode.Impulse);
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
