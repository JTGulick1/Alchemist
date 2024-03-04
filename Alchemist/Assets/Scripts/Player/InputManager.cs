using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InputManager : MonoBehaviour
{
    private static InputManager _instance;
    public static InputManager Instance
    {
        get
        {
            return _instance;
        }
    }

    private PlayerControlls inputActions;

    private void Awake()
    {
        if (_instance != null && _instance != this)
        {
            Destroy(this.gameObject);
        }
        else
        {
            _instance = this;
        }
        inputActions = new PlayerControlls();
    }

    private void OnEnable()
    {
        inputActions.Enable();
    }

    private void OnDisable()
    {
        inputActions.Disable();
    }

    public bool Interact()
    {
        return inputActions.Keyboard.Interact.triggered;
    }

    public Vector2 GetPlayerMovement()
    {
        return inputActions.Keyboard.Movement.ReadValue<Vector2>();
    }

    public bool Sprint()
    {
        return inputActions.Keyboard.Sprint.IsPressed();
    }

}
