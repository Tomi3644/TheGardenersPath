using System.Collections;
using System.Runtime.CompilerServices;
using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    private CharacterController controller;
    private Vector3 playerVelocity;
    private bool isGrounded;
    private bool canBounce = true;
    private bool canJump = true;
    private bool bounced;
    private bool isJumping;
    private bool isOnLadder;
    private InputManager inputManager;
    private Transform cameraTransform;
    private float gravityValue;
    private float previousHeight;
    private PlayerInput playerInput;

    [SerializeField]
    private float playerSpeed;
    [SerializeField]
    private float jumpHeight;
    [SerializeField]
    private float normalGravity;
    [SerializeField]
    private float fallGravity;
    [SerializeField]
    private float bounceHeight;
    private void Start()
    {
        gravityValue = normalGravity;
        inputManager = InputManager.Instance;
        cameraTransform = Camera.main.transform;
        controller = GetComponent<CharacterController>();
        playerInput = GetComponent<PlayerInput>();
    }

    void Update()
    {
        // Check if player on the ground
        isGrounded = Physics.SphereCast(transform.position, 0.5f, -transform.up, out RaycastHit groundHit, 0.6f, 1 << 3);

        if (isGrounded && playerVelocity.y < 0)
        {
            playerVelocity.y = -0.1f;
        }

        // Get player inputs and move accordingly
        // If on ladder, player goes up
        Vector2 movement = inputManager.GetPlayerMovement();
        Vector3 move = new Vector3(movement.x, 0f, movement.y);
        if (isOnLadder && movement.y > 0f)
        {
            move = Vector3.up * move.z + transform.right * move.x;
        }
        else
        {
            move = cameraTransform.forward * move.z + cameraTransform.right * move.x;
            move.y = 0f;
        }
        
        controller.Move(move * Time.deltaTime * playerSpeed);

        // Player jump on input if on layer Ground
        isJumping = inputManager.PlayerJumpedThisFrame();

        if (isJumping && isGrounded && canJump)
        {
            playerVelocity.y += Mathf.Sqrt(jumpHeight * -2.0f * gravityValue);
            canJump = false;
            StartCoroutine(JumpWait());
        }

        // Player automatically jump if on layer Bouncer and cannot bounce twice in two frames
        if (Physics.SphereCast(transform.position, 0.48f, -transform.up, out RaycastHit bouncerHit, 0.6f, 1 << 6))
        {
            if (canBounce && playerVelocity.y <= 0f)
            {
                playerVelocity.y = Mathf.Sqrt(bounceHeight * -2.0f * gravityValue);
                canBounce = false;

                StartCoroutine(BounceWait());
            }
        }

        // Gravity application on player (different if on ladder)
        if (!isOnLadder && movement.y <= 0f) playerVelocity.y += gravityValue * Time.deltaTime;
        controller.Move(playerVelocity * Time.deltaTime);

        var currentHeight = transform.position.y;
        if (currentHeight + 0.02f < previousHeight)
        {
            gravityValue = fallGravity;
        }
        else { gravityValue = normalGravity; }
        previousHeight = transform.position.y;
    }

    // Timer to prevent from jumping/bouncing twice in two frames
    private IEnumerator BounceWait()
    {
        yield return new WaitForSeconds(.5f);
        canBounce = true;
    }

    private IEnumerator JumpWait()
    {
        yield return new WaitForSeconds(.1f);
        canJump = true;
    }
    
    // Trigger handling for ladder
    void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Ladder")
        {
            isOnLadder = true;
        }
    }
    void OnTriggerExit(Collider other)
    {
        if (other.tag == "Ladder")
        {
            isOnLadder = false;
        }
    }
}
