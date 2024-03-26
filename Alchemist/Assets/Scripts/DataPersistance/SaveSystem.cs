using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SaveSystem : MonoBehaviour
{
    DataPersistanceManager data;

    public string filename = "Data.txt";

    private void Awake()
    {
        DontDestroyOnLoad(this.gameObject);
    }



    public void ChangeFileName(string other)
    {
        filename = other + filename;
    }
}
