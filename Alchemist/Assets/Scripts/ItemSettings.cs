using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ItemSettings : MonoBehaviour
{
    public enum Itemtype
    {
        Fresh,
        Cut,
        Molded,
        Cooked,
        Brewed
    }
    public Itemtype itemtype;
}
