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

    public bool PlayerThrewThisFrame()
    {
        return playerInputs.Game.Throw.triggered;
    }

    public int PlayerChangedSeedButton()
    {
        if (playerInputs.Game.Seed1.triggered) return 1;
        else if (playerInputs.Game.Seed2.triggered) return 2;
        else if (playerInputs.Game.Seed3.triggered) return 3;
        else if (playerInputs.Game.Seed4.triggered) return 4;
        else return 0;
    }

    public float PlayerScrolled()
    {
        if (playerInputs.Game.GamepadSeedForward.triggered)
            return 1f;
        else if (playerInputs.Game.GamepadSeedBackward.triggered)
            return -1f;
        else return playerInputs.Game.ScrollSeeds.ReadValue<float>();
    }
}
