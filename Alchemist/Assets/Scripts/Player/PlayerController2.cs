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
    private QuestBoard questBoard;
    private float playerBaseSpeed = 30.0f;
    private float sprintingSpeed = 50.0f;
    private float slowedSpeed = 10.0f;
    public PlayerInput PlayerInput => playerInput;

    public bool cBrew = false;
    public bool isHolding = false;
    public bool cantSprint = false;
    public GameObject playerHolder;
    public GameObject carry;
    public bool closeToBoard = false;
    public GameObject bOrder;
    public GameObject thrownItem;

    private EventSystem eventSystem;
    public bool closeToCust = false;
    public GameObject order;
    AI_Customer closestCust;
    private Currency currency;
    public GameObject vestHolder;
    public GameObject vest;
    public BookSmall bookS;
    private bool isBookOpen = false;
    public bool frozenPlayer = false;
    private float gravity = -9.81f;
    private float verticalVelocity = 0f;

    public GameObject arms;

    private void Start()
    {
        inputManager = InputManager.Instance;
        playerInput = GetComponent<PlayerInput>();
        controller = GetComponent<CharacterController>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
        player = GameObject.FindGameObjectWithTag("Player").GetComponent<PlayerController>();
        eventSystem = GameObject.FindGameObjectWithTag("EventSystem").GetComponent<EventSystem>();
        Cursor.lockState = CursorLockMode.Locked;
        bOrder = player.bOrder;
        questBoard = GameObject.FindGameObjectWithTag("QuestBoard").GetComponent<QuestBoard>();
        bookS = GameObject.FindGameObjectWithTag("BookP2").GetComponent<BookSmall>();
        bookS.gameObject.SetActive(false);
    }

    private void Update()
    {

        if (frozenPlayer == true)
        {
            playerSpeed = 0;
            return;
        }
        if (inputManager.SprintP2() == true)
        {
            playerSpeed = sprintingSpeed;
        }
        else if (cantSprint == true)
        {
            playerSpeed = slowedSpeed;
        }
        else
        {
            playerSpeed = playerBaseSpeed;
        }

        if (inputManager.PotionsBookP2())
        {
            OpenPotionBook();
        }
        if (inputManager.PageTurnLeft())
        {
            bookS.pageNum--;
            bookS.UpdatePage();
        }
        if (inputManager.PageTurnRight())
        {
            bookS.pageNum++;
            bookS.UpdatePage();
        }
        if (inputManager.ThrowP2() == true && isHolding == true)
        {
            Throw();
        }

        Vector2 movement = inputManager.GetPlayerMovementP2();
        Vector3 move = new Vector3(movement.x, 0f, movement.y);
        if (controller.isGrounded)
        {
            verticalVelocity = 0;
        }
        else
        {
            verticalVelocity += gravity * Time.deltaTime;
        }
        move.y = verticalVelocity;
        controller.Move(move * Time.deltaTime * (playerSpeed / 4));
        if (carry != null && carry.tag == "Holder")
        {
            if (closeToCust == true && carry.GetComponent<BrewSettings>().temp == order.GetComponent<BrewSettings>().title &&
                   carry.GetComponent<BrewSettings>().isPot == true && inputManager.InteractP2())
            {
                closestCust.LeaveStore();
                closestCust.Served();
                currency.GetGold(carry.GetComponent<BrewSettings>().price);
                Destroy(carry);
                isHolding = false;
            }
        }
        if (carry != null && carry.tag == "Holder")
        {
            if (closeToBoard == true && carry.GetComponent<BrewSettings>().temp == bOrder.GetComponent<BrewSettings>().title &&
                   carry.GetComponent<BrewSettings>().isPot == true && inputManager.InteractP2())
            {
                questBoard.stock++;
                Destroy(carry);
                isHolding = false;
                if (questBoard.stock >= questBoard.quota)
                {
                    questBoard.QuestComplete();
                }
                questBoard.UpdateText();
            }
        }
    }

    public void Throw()
    {
        isHolding = false;
        thrownItem = Instantiate(carry, playerHolder.transform.position, playerHolder.transform.rotation);
        if (thrownItem.tag == "Holder")
        {
            thrownItem.GetComponent<BrewSettings>().Grounded(arms.transform.forward);
        }
        else
        {
            thrownItem.GetComponent<ItemSettings>().Grounded(arms.transform.forward);
        }
        Destroy(carry);
    }

    public void PickUpObject(GameObject item)
    {
        isHolding = true;
        carry = Instantiate(item, playerHolder.transform.position, playerHolder.transform.rotation, playerHolder.transform);
        if (item.tag == "Holder")
        {
            carry.GetComponent<BrewSettings>().Held();
        }
        else
        {
            carry.GetComponent<ItemSettings>().Held();
        }
        Destroy(item);
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
    public void ToFarFromBoard()
    {
        closeToBoard = false;
    }
    public void QuestBoard(GameObject boardO)
    {
        closeToBoard = true;
        bOrder = boardO;
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

    public void OpenPotionBook()
    {
        if (isBookOpen == false)
        {
            bookS.gameObject.SetActive(true);
            isBookOpen = true;
            return;
        }
        if (isBookOpen == true)
        {
            bookS.gameObject.SetActive(false);
            isBookOpen = false;
            return;
        }
    }

}
