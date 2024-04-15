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

    public bool SpawnP2()
    {
        return inputActions.Keyboard.SpawnP2.IsPressed();
    }

    public bool Exit()
    {
        return inputActions.Keyboard.Exit.IsPressed();
    }

    public bool PotionsBook()
    {
        return inputActions.Keyboard.PotionsBook.triggered;
    }

    // Player 2 Controls
    public bool InteractP2()
    {
        return inputActions.Controller.Interact.triggered;
    }

    public Vector2 GetPlayerMovementP2()
    {
        return inputActions.Controller.Movement.ReadValue<Vector2>();
    }

    public bool SprintP2()
    {
        return inputActions.Controller.Sprint.IsPressed();
    }

    public Vector2 GetPlayer2MouseMovement()
    {
        return inputActions.Controller.MouseMovement.ReadValue<Vector2>();
    }

    public bool P2Select()
    {
        return inputActions.Controller.ControllerSelect.triggered;
    }

    public bool PotionsBookP2()
    {
        return inputActions.Controller.PotionsBook.triggered;
    }

}