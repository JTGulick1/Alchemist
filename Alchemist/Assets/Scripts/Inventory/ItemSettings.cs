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
}
