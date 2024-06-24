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
    public PlayerInput PlayerInput => playerInput;
    public bool isHolding = false;
    public GameObject playerHolder;
    public GameObject carry;
    public GameObject thrownItem;

    public bool cBrew = false;
    public bool closeToCust = false;
    public bool closeToBoard = false;
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
        bookS = Pbook.GetComponent<BookSmall>();
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
        if (inputManager.Sprint() == true)
        {
            playerSpeed = sprintingSpeed;
        }
        else
        {
            playerSpeed = playerBaseSpeed;
        }
        if (inputManager.Throw() == true && isHolding == true)
        {
            isHolding = false;
            thrownItem = Instantiate(carry, playerHolder.transform.position, playerHolder.transform.rotation);
            if (thrownItem.tag == "Holder")
            {
                thrownItem.GetComponent<BrewSettings>().Grounded();
            }
            else
            {
                thrownItem.GetComponent<ItemSettings>().Grounded();
            }
            Destroy(carry);
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

    public void PickUpObject(GameObject item)
    {
        isHolding = true;
        carry = Instantiate(item, playerHolder.transform.position, playerHolder.transform.rotation, playerHolder.transform);
        if (thrownItem.tag == "Holder")
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
        Player2.GetComponent<PlayerController2>().bookS = bookS2.GetComponent<BookSmall>();
        bookS2.SetActive(false);
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
