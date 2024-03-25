using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class DataPersistanceManager : MonoBehaviour
{
    private GameData gameData;
    private List<IDataPersistance> DataPersistanceObjects;
    [SerializeField] private string fileName;
    [SerializeField] private bool useEncription;
    private FileDataHandler dataHandler;
    public static DataPersistanceManager instance { get; private set; }

    private void Awake()
    {
        if (instance != null)
        {
            Debug.LogError("Found more then one data persistance managers in the scene");
        }
        instance = this;
    }

    public void Start()
    {
        dataHandler = new FileDataHandler(Application.persistentDataPath, fileName, useEncription);
        this.DataPersistanceObjects = FindAllDataPersistanceObjects();
        LoadGame();
    }

    public void NewGame()
    {
        this.gameData = new GameData();
    }

    public void LoadGame()
    {
        this.gameData = dataHandler.Load();

        if (this.gameData == null)
        {
            Debug.Log("No Data Found");
            NewGame();
        }
        foreach (IDataPersistance dataPersistance in DataPersistanceObjects)
        {
            dataPersistance.LoadData(gameData);
        }

        Debug.Log("Loaded Currency Count:" + gameData.coins);
    }

    public void SaveData()
    {
        foreach (IDataPersistance dataPersistance in DataPersistanceObjects)
        {
            dataPersistance.SaveData(ref gameData);
        }
        Debug.Log("Saved Currency Count:" + gameData.coins);

        dataHandler.Save(gameData);
    }

    private List<IDataPersistance> FindAllDataPersistanceObjects()
    {
        IEnumerable<IDataPersistance> dataPersistances = FindObjectsOfType<MonoBehaviour>().OfType<IDataPersistance>();

        return new List<IDataPersistance>(dataPersistances);
    }

    private void OnApplicationQuit()
    {
        SaveData();
    }
}
