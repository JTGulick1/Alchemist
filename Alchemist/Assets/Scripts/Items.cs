using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenuAttribute(fileName = "New Item", menuName = "Item Creation/Items")]
public class Item : ScriptableObject
{
    public string title = "Item";
    public enum ItemType
    {
        Fresh,
        Cut,
        Molded,
        Brewed,
        Cooked
    }
    public ItemType itemType;
}