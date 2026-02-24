using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerController : MonoBehaviour
{
    private CharacterController controller;
    private Vector3 playerVelocity;
    private bool isGrounded;
    private bool isJumping;
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
        isGrounded = Physics.SphereCast(transform.position,0.5f,-transform.up,out RaycastHit hit,0.6f, 1 << 3);
        if (isGrounded && playerVelocity.y < 0)
        {
            playerVelocity.y = -0.1f;
        }

        Vector2 movement = inputManager.GetPlayerMovement();
        Vector3 move = new Vector3(movement.x, 0f, movement.y);
        move = cameraTransform.forward * move.z + cameraTransform.right * move.x;
        move.y = 0f;
        controller.Move(move * Time.deltaTime * playerSpeed);
        
        isJumping = inputManager.PlayerJumpedThisFrame();
        if (isJumping && isGrounded)
        {
            playerVelocity.y += Mathf.Sqrt(jumpHeight * -2.0f * gravityValue);
        }

        playerVelocity.y += gravityValue * Time.deltaTime;
        controller.Move(playerVelocity * Time.deltaTime);

        var currentHeight = transform.position.y;
        if (currentHeight + 0.02f < previousHeight)
        {
            gravityValue = fallGravity;
        }
        else { gravityValue = normalGravity; }
        previousHeight = transform.position.y;
    }
}
