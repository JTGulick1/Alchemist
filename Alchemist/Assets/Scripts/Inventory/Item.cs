using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenuAttribute(fileName = "New Item", menuName = "Item Creation/Items")]
public class Item : ScriptableObject
{
    public string title = "Item";
    public Sprite image;
    public int cost = 0;
    public int saveNum = 0;
    public GameObject physicalForm;
}