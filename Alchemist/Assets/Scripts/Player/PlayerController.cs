using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    [SerializeField]
    private float playerSpeed = 30.0f;
    private bool frovenPlayer = false;
    private PlayerInput playerInput = null;
    private InputManager inputManager;
    private CharacterController controller;
    private InventoryManager inventory;
    private ShopManager shop;
    private QuestBoard questBoard;
    private GameObject Player2IRL;
    private float playerBaseSpeed = 30.0f;
    private float sprintingSpeed = 50.0f;
    private float slowedSpeed = 10.0f;
    public PlayerInput PlayerInput => playerInput;
    public bool isHolding = false;
    public GameObject playerHolder;
    public GameObject carry;
    public GameObject thrownItem;

    public bool cBrew = false;
    public bool closeToCust = false;
    public bool closeToBoard = false;
    public bool cantSprint = false;
    public GameObject order;
    public GameObject bOrder;
    private AI_Customer closestCust;
    private Currency currency;
    public bool P2S = false;
    public GameObject Player2;
    public Camera cam;
    public GameObject vestHolder;
    public GameObject vest;
    public GameObject Pbook;
    public GameObject PbookS;
    public Book book;
    public BookSmall bookS;
    public GameObject bookS2;
    private bool isBookOpen = false;
    private float gravity = -9.81f;
    private float verticalVelocity = 0f;
    public GameObject PauseMenu;
    public WorldTimer timer;

    public float sensitivity = 100f;
    private float rotationY = 0f;
    public GameObject arms;

    private void Start()
    {
        inputManager = InputManager.Instance;
        playerInput = GetComponent<PlayerInput>();
        controller = GetComponent<CharacterController>();
        currency = GameObject.FindGameObjectWithTag("Currency").GetComponent<Currency>();
        inventory = GameObject.FindGameObjectWithTag("Inventory").GetComponent<InventoryManager>();
        shop = GameObject.FindGameObjectWithTag("Shop").GetComponent<ShopManager>();
        questBoard = GameObject.FindGameObjectWithTag("QuestBoard").GetComponent<QuestBoard>();
        Cursor.lockState = CursorLockMode.Locked;
        Pbook.SetActive(false);
        PbookS.SetActive(false);
        book = Pbook.GetComponent<Book>();
        bookS = PbookS.GetComponent<BookSmall>();
        timer = GameObject.FindGameObjectWithTag("Timer").GetComponent<WorldTimer>();
        PauseMenu.SetActive(false);
    }

    private void Update()
    {
        if (frovenPlayer == true)
        {
            playerSpeed = 0;
            return;
        }
        if (inputManager.PotionsBook())
        {
            OpenPotionBook();
        }
        if (P2S == false && inputManager.SpawnP2() == true)
        {
            SpawnP2();
            inventory.Joined();
            shop.Joined();
            bookS2.GetComponent<BookSmall>().Joined();
        }
        if (inputManager.Sprint() == true && cantSprint == false)
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
        if (inputManager.Pause())
        {
            PauseGame();
        }

        if (inputManager.Throw() == true && isHolding == true)
        {
            Throw();
        }

        // Get mouse movement input
        float mouseX = Input.GetAxis("Mouse X");

        // Calculate the rotation amount
        rotationY += mouseX * sensitivity * Time.deltaTime;

        // Apply the rotation to the player
        transform.localRotation = Quaternion.Euler(0, rotationY, 0);

        Vector2 movement = inputManager.GetPlayerMovement();
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
                   carry.GetComponent<BrewSettings>().isPot == true && inputManager.Interact())
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
                   carry.GetComponent<BrewSettings>().isPot == true && inputManager.Interact())
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

    public void PauseGame()
    {
        Cursor.lockState = CursorLockMode.None;
        frovenPlayer = true;
        Player2.GetComponent<PlayerController2>().frozenPlayer = true;
        PauseMenu.SetActive(true);
        timer.PauseTime(0);
    }

    public void ResumeGame()
    {
        Cursor.lockState = CursorLockMode.Locked;
        frovenPlayer = false;
        Player2.GetComponent<PlayerController2>().frozenPlayer = false;
        PauseMenu.SetActive(false);
        timer.PauseTime(1);
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

    public void SpawnP2()
    {
        cam.rect = new Rect(0, 0.5f, 1, 0.5f);
        P2S = true;
        Player2IRL = Instantiate(Player2);
        questBoard.Player2Spawn();
        bookS2.SetActive(true);
    }

    public void OpenPotionBook()
    {
        if (P2S == false)
        {
            if (isBookOpen == false)
            {
                Cursor.lockState = CursorLockMode.None;
                Pbook.SetActive(true);
                isBookOpen = true;
                return;
            }
            if (isBookOpen == true)
            {
                Cursor.lockState = CursorLockMode.Locked;
                Pbook.SetActive(false);
                isBookOpen = false;
                return;
            }
        }
        if (P2S == true)
        {
            if (isBookOpen == false)
            {
                Cursor.lockState = CursorLockMode.None;
                PbookS.SetActive(true);
                isBookOpen = true;
                return;
            }
            if (isBookOpen == true)
            {
                Cursor.lockState = CursorLockMode.Locked;
                PbookS.SetActive(false);
                isBookOpen = false;
                return;
            }
        }
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

    public void QuestBoard(GameObject boardO)
    {
        closeToBoard = true;
        bOrder = boardO;
    }

    public void ToFarFromCust()
    {
        closeToCust = false;
    }

    public void ToFarFromBoard()
    {
        closeToBoard = false;
    }

    public void FreezePlayer()
    {
        frovenPlayer = true;
    }
    public void UnFreezePlayer()
    {
        frovenPlayer = false;
    }

    public void CompletedQuest(int q)
    {
        currency.GetGold(q);
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
