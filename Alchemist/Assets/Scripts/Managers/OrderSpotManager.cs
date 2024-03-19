using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class OrderSpotManager : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("Entered");
        if (other.tag == "Customer")
        {
            Debug.Log("Entered Cust");
            this.tag = "Taken";
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Customer")
        {
            this.tag = "Order Spot";
        }
    }
}
