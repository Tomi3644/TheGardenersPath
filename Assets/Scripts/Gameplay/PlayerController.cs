using System.Collections;
using System.Runtime.CompilerServices;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.Events;

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
    private float? lastGroundedTime;
    private float? jumpButtonPressedTime;
    private bool canUseCoyote, hasJumpInput;

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
    [SerializeField]
    private float groundSphereSize;
    [SerializeField]
    private float coyoteTime = 0.2f;

    [Header("Sounds")]
    [SerializeField] private AudioClip mushroomBounceSFX;
    private bool isWalking, isClimbing;
    [SerializeField] private GameObject creditsTransition;
    public UnityEvent endDeactivation;

    private void Start()
    {
        gravityValue = normalGravity;
        inputManager = InputManager.Instance;
        cameraTransform = Camera.main.transform;
        controller = GetComponent<CharacterController>();
        Cursor.visible = false;
    }

    void Update()
    {
        bool bouncedThisFrame = false;
        gravityValue = normalGravity;

        // Check if player on the ground
        isGrounded = Physics.SphereCast(transform.position, groundSphereSize, -transform.up, out RaycastHit groundHit, 0.6f, 1 << 3);

        // Get player inputs and move accordingly
        // If on ladder, player goes up
        Vector2 movement = inputManager.GetPlayerMovement();
        Vector3 move = new Vector3(movement.x, 0f, movement.y);

        Vector3 forward = cameraTransform.forward;
        forward.y = 0f;
        forward.Normalize();

        Vector3 right = cameraTransform.right;
        right.y = 0f;
        right.Normalize();

        if (isOnLadder && movement.y > 0f)
        {
            move = Vector3.up * move.z + transform.right * move.x;
        }
        else
        {
            move = forward * move.z + right * move.x;
            move.y = 0f;
        }
        playerVelocity.x = move.x * playerSpeed;
        if (move.y != 0f) playerVelocity.y = move.y * playerSpeed;
        playerVelocity.z = move.z * playerSpeed;

        // Player automatically jump if on layer Bouncer and cannot bounce twice in two frames
        if (Physics.SphereCast(transform.position, 0.48f, -transform.up, out RaycastHit bouncerHit, 0.6f, 1 << 6))
        {
            if (canBounce && playerVelocity.y <= 0f)
            {
                playerVelocity.y = Mathf.Sqrt(bounceHeight * -2.0f * gravityValue);
                canBounce = false;
                bouncedThisFrame = true;
                SFXManager.instance.PlaySFX(mushroomBounceSFX);

                StartCoroutine(BounceWait());
            }
        }

        // Player jump on input if on layer Ground
        isJumping = inputManager.PlayerJumpedThisFrame();

        if (isJumping) jumpButtonPressedTime = Time.time;
        if (isGrounded) lastGroundedTime = Time.time;

        canUseCoyote = Time.time - lastGroundedTime <= coyoteTime;
        hasJumpInput = Time.time - jumpButtonPressedTime <= coyoteTime;

        if ((isGrounded || canUseCoyote) && hasJumpInput && canJump && !isOnLadder)
        {
            playerVelocity.y = 0f;
            playerVelocity.y = Mathf.Sqrt(jumpHeight * -2f * normalGravity);

            canJump = false;
            jumpButtonPressedTime = null;
            lastGroundedTime = null;

            StartCoroutine(JumpWait());
        }
        
        // Gravity application on player (different if on ladder)
        if (!isOnLadder && !bouncedThisFrame) playerVelocity.y += gravityValue * Time.deltaTime;

        var currentHeight = transform.position.y;
        if (currentHeight + 0.02f < previousHeight)
        {
            gravityValue = fallGravity;
        }
        else { gravityValue = normalGravity; }
        previousHeight = transform.position.y;

        // Set booleans for SFX
        if (playerVelocity.x != 0f || playerVelocity.z != 0f)
        {
            // Footsteps
            if (!isOnLadder && isGrounded)
            {
                isWalking = true;
                isClimbing = false;
            }
            else if (isOnLadder)
            {
                isWalking = false;
                isClimbing = true;
            }
            else
            {
                isWalking = false;
                isClimbing = false;
            }
        }
        else
        {
            isWalking = false;
            isClimbing = false;
        }
        if (isWalking != SFXManager.instance.walking)
        {
            SFXManager.instance.walking = isWalking;
            if (isWalking == true && SFXManager.instance.footstepsCoroutineStarted == false) StartCoroutine(SFXManager.instance.FootstepsSFX());
        }
        if (isClimbing != SFXManager.instance.climbing)
        {
            SFXManager.instance.climbing = isClimbing;
            if (isClimbing == true && SFXManager.instance.climbingCoroutineStarted == false) StartCoroutine(SFXManager.instance.ClimbingSFX());
        }

        // Final movement
        controller.Move(playerVelocity * Time.deltaTime);
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
        else if (other.tag == "Finish")
        {
            creditsTransition.SetActive(true);
            SFXManager.instance.walking = false;
            endDeactivation.Invoke();
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
