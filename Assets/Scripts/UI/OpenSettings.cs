using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;

public class OpenSettings : MonoBehaviour
{
    private InputManager inputManager;
    private GameObject menu;

    private void Start()
    {
        inputManager = InputManager.Instance;
        menu = GameObject.Find("PauseMenu");
        menu.SetActive(false);
    }

    // Update is called once per frame
    private void Update()
    {
        if (inputManager.OpeningSettingsMenu())
        {
            menu.SetActive(true);
        }
    }
}
