using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Player2Clicker : MonoBehaviour
{
    InputManager input;
    void Start()
    {
        input = InputManager.Instance;
    }

    void Update()
    {
        if (input.P2Select())
        {

        }
    }
}
