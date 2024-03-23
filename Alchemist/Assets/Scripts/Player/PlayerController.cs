using System;
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
    private InventoryManager inventory;
    private ShopManager shop;
    private GameObject Player2IRL;
    private float playerBaseSpeed = 30.0f;
    private float sprintingSpeed = 50.0f;
    public PlayerInput PlayerInput => playerInput;

    public bool isHolding = false;
    public GameObject playerHolder;
    public GameObject carry;

    public bool closeToCust = false;
    public GameObject order;
    AI_Customer closestCust;
    private Currency currency;

    public bool P2S = false;
    public GameObject Player2;
    public Camera cam;
    private void Start()
    {
        inputManager = InputManager.Instance;
        playerInput = GetComponent<PlayerInput>();
        controller = GetComponent<CharacterController>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
        inventory = GameObject.FindGameObjectWithTag("Inventory").GetComponent<InventoryManager>();
        shop = GameObject.FindGameObjectWithTag("Shop").GetComponent<ShopManager>();
        Cursor.lockState = CursorLockMode.Locked;
    }

    private void Update()
    {
        if (P2S == false && inputManager.SpawnP2() == true)
        {
            SpawnP2();
            inventory.Joined();
            shop.Joined();
        }
        if (inputManager.Sprint() == true)
        {
            playerSpeed = sprintingSpeed;
        }
        else
        {
            playerSpeed = playerBaseSpeed;
        }
        Vector2 movement = inputManager.GetPlayerMovement();
        Vector3 move = new Vector3(movement.x, 0f, movement.y);
        move.y = 0f;
        controller.Move(move * Time.deltaTime * (playerSpeed / 4));
        if (carry != null && carry.tag == "Holder")
        {
            if (closeToCust == true && carry.GetComponent<BrewSettings>().temp == order.GetComponent<BrewSettings>().title &&
                   carry.GetComponent<BrewSettings>().isPot == true && inputManager.Interact())
            {
                closestCust.LeaveStore();
                currency.GetGold(carry.GetComponent<BrewSettings>().price);
                Destroy(carry);
                isHolding = false;
            }
        }
    }

    public void SpawnP2()
    {
        cam.rect = new Rect(0, 0.5f, 1, 0.5f);
        P2S = true;
        Player2IRL = Instantiate(Player2);
    }

    public void player1Action()
    {
        cam.rect = new Rect(0, 0, 1, 1);
        Player2IRL.SetActive(false);
    }

    public void player1ActionExit()
    {
        cam.rect = new Rect(0, 0.5f, 1, 0.5f);
        Player2IRL.SetActive(true);
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
