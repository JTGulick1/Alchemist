using UnityEngine;

public class WallAndRoofHider : MonoBehaviour
{
    public GameObject roof;
    public GameObject backWall;

    private void OnTriggerStay(Collider other)
    {
        if(other.tag == "Player")
        {
            roof.SetActive(false);
            backWall.SetActive(false);
        }
    }
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            roof.SetActive(false);
            backWall.SetActive(false);
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Player")
        {
            roof.SetActive(true);
            backWall.SetActive(true);
        }
    }
}
