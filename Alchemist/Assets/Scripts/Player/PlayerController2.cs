using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.EventSystems;

public class PlayerController2 : MonoBehaviour
{
    [SerializeField]
    private float playerSpeed = 30.0f;
    private PlayerInput playerInput = null;
    private InputManager inputManager;
    private CharacterController controller;
    private PlayerController player;
    private float playerBaseSpeed = 30.0f;
    private float sprintingSpeed = 50.0f;
    public PlayerInput PlayerInput => playerInput;

    public bool isHolding = false;
    public GameObject playerHolder;
    public GameObject carry;

    private EventSystem eventSystem;
    public bool closeToCust = false;
    public GameObject order;
    AI_Customer closestCust;
    private Currency currency;
    private void Start()
    {
        inputManager = InputManager.Instance;
        playerInput = GetComponent<PlayerInput>();
        controller = GetComponent<CharacterController>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        eventSystem = GameObject.FindGameObjectWithTag("EventSystem").GetComponent<EventSystem>();
        Cursor.lockState = CursorLockMode.Locked;
    }

    private void Update()
    {
        if (inputManager.SprintP2() == true)
        {
            playerSpeed = sprintingSpeed;
        }
        else
        {
            playerSpeed = playerBaseSpeed;
        }
        Vector2 movement = inputManager.GetPlayerMovementP2();
        Vector3 move = new Vector3(movement.x, 0f, movement.y);
        move.y = 0f;
        controller.Move(move * Time.deltaTime * (playerSpeed / 4));
        if (carry != null && carry.tag == "Holder")
        {
            if (closeToCust == true && carry.GetComponent<BrewSettings>().temp == order.GetComponent<BrewSettings>().title &&
                   carry.GetComponent<BrewSettings>().isPot == true && inputManager.InteractP2())
            {
                closestCust.LeaveStore();
                currency.GetGold(carry.GetComponent<BrewSettings>().price);
                Destroy(carry);
                isHolding = false;
            }
        }
    }

    public void selected(GameObject first)
    {
        eventSystem.SetSelectedGameObject(first);
    }

    public void CustomerOrder(GameObject custO, AI_Customer customer)
    {
        closeToCust = true;
        order = custO;
        closestCust = customer;
    }

    public void ToFarFromCust()
    {
        closeToCust = false;
    }

    public void FreezePlayer()
    {
        playerSpeed = 0.0f;
    }
    public void UnFreezePlayer()
    {
        playerSpeed = playerBaseSpeed;
    }

    public ItemSettings.Itemtype GetType()
    {
        return carry.GetComponent<ItemSettings>().itemtype;
    }

    public void SetType(ItemSettings.Itemtype type)
    {
        carry.GetComponent<ItemSettings>().itemtype = type;
    }
}
