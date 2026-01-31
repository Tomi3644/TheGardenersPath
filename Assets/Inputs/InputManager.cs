using UnityEngine;
using UnityEngine.InputSystem;

public class InputManager : MonoBehaviour
{
    private static InputManager _instance;
    public static InputManager Instance {
        get {
            return _instance;
        }
    }

    private PlayerInputActions playerInputs;

    private void Awake()
    {
        if (_instance != null && _instance != this)
        {
            Destroy(this.gameObject);
        }
        else { _instance = this; }

        playerInputs = new PlayerInputActions();
    }
    
    private void OnEnable() {
        playerInputs.Enable();
    }
    private void OnDisable() {
        playerInputs.Disable();
    }

    public Vector2 GetPlayerMovement(){
        return playerInputs.Game.Move.ReadValue<Vector2>();
    }

    public bool PlayerJumpedThisFrame()
    {
        return playerInputs.Game.Jump.triggered;
    }
}
