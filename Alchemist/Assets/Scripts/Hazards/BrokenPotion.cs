using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BrokenPotion : MonoBehaviour
{
    private PlayerController player;
    private PlayerController2 player2;
    private float lifetime = 30f;

    private void Update()
    {
        lifetime -= Time.deltaTime;
        if (lifetime <= 0.0f)
        {
            Destroy(this.gameObject);
        }
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            player = other.GetComponent<PlayerController>();
            player.cantSprint = true;
        }
        if (other.tag == "Player2")
        {
            player2 = other.GetComponent<PlayerController2>();
            player2.cantSprint = true;
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            player.cantSprint = false;
        }
        if (other.tag == "Player2")
        {
            player2.cantSprint = false;
        }
    }
}
