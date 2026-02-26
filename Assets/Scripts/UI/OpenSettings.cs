using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.InputSystem;

public class OpenSettings : MonoBehaviour
{
    private InputManager inputManager;
    private GameObject pause;
    private GameObject settings;

    private void Start()
    {
        inputManager = InputManager.Instance;
        pause = GameObject.Find("PauseMenu");
        settings = GameObject.Find("SettingsMenu");
        pause.SetActive(false);
        settings.SetActive(false);
    }

    // Update is called once per frame
    private void Update()
    {
        if (inputManager.OpeningSettingsMenu())
        {
            pause.SetActive(true);
        }
    }
}
