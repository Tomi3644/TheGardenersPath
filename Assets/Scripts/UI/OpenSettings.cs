using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;

public class OpenSettings : MonoBehaviour
{
    private InputManager inputManager;
    [SerializeField] private GameObject pause;
    [SerializeField] private GameObject settings;
    [SerializeField] private GameObject inputs;

    private void Start()
    {
        inputManager = InputManager.Instance;
        inputManager.gameObject.SetActive(false);
    }

    // Update is called once per frame
    private void Update()
    {
        if (inputManager.OpeningSettingsMenu())
        {
            pause.SetActive(true);
            inputs.SetActive(false);
        }
    }
}
