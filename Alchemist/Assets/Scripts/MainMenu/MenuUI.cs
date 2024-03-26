using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
public class MenuUI : MonoBehaviour
{
    public GameObject MenuCan;
    public GameObject SavesCan;
    public GameObject optionsCan;

    private void Start()
    {
        SavesCan.SetActive(false);
        MenuCan.SetActive(true);
        optionsCan.SetActive(false);
    }

    public void OpenLoadMenu()
    {
        SavesCan.SetActive(true);
        MenuCan.SetActive(false);
    }

    public void OpenSave(int n)
    {
        SceneManager.LoadScene("Shop");
    }

    public void OpenOptions()
    {
        MenuCan.SetActive(false);
        optionsCan.SetActive(true);
    }

    public void OpenMenu()
    {
        SavesCan.SetActive(false);
        MenuCan.SetActive(true);
        optionsCan.SetActive(false);
    }

    public void LeaveGame()
    {
        Application.Quit();
    }
}
