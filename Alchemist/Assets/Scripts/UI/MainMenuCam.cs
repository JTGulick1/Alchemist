using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MainMenuCam : MonoBehaviour
{
    public Vector3 rotationSpeed = new Vector3(0, 100, 0); // Rotation speed in degrees per second

    void Update()
    {
        // Rotate the object based on the rotationSpeed and the time passed since the last frame
        transform.Rotate(rotationSpeed * Time.deltaTime);
    }
}
