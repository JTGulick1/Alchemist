using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    [SerializeField]
    private float playerSpeed = 30.0f;
    private PlayerInput playerInput = null;
    private InputManager inputManager;
    private CharacterController controller;

    private float playerBaseSpeed = 30.0f;
    private float sprintingSpeed = 50.0f;
    public PlayerInput PlayerInput => playerInput;

    private void Start()
    {
        inputManager = InputManager.Instance;
        playerInput = GetComponent<PlayerInput>();
        controller = GetComponent<CharacterController>();
        Cursor.lockState = CursorLockMode.Locked;
    }

    private void Update()
    {
        if (inputManager.Sprint() == true){
            playerSpeed = sprintingSpeed;
        }
        else{
            playerSpeed = playerBaseSpeed;
        }
        Vector2 movement = inputManager.GetPlayerMovement();
        Vector3 move = new Vector3(movement.x, 0f, movement.y);
        move.y = 0f;
        controller.Move(move * Time.deltaTime * (playerSpeed / 4));


    }
}
