using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RedecorateButton : MonoBehaviour
{
    public GameObject obj;
    public GameObject spawn;
    public bool objHere;
    public Redecoracate decoracate;

    public void MoveObj()
    {
        if (objHere == true && decoracate.holding == null)
        {
            decoracate.GrabbedObject(obj);
            Destroy(obj);
            objHere = false;
            return;
        }
        if (objHere == false)
        {
            obj = Instantiate(decoracate.PlaceObject(), spawn.transform.position, spawn.transform.rotation);
            Destroy(decoracate.holding);
            objHere = true;
            return;
        }
    }
}