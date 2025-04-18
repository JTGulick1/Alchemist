using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

[CreateAssetMenuAttribute(fileName = "New Brew", menuName = "Item Creation/Brews")]
public class Brews : ScriptableObject
{
    public string brewName = "Name";
    public GameObject physicalForm;
    public Sprite image;
    public int price;
    public int saveInt;
    public ItemSettings Ing1;
    public ItemSettings Ing2;
    public ItemSettings Ing3;
}
