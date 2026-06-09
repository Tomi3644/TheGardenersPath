using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public enum MenuState
{
    MainMenu,
    PauseMenu,
    Settings
}

public class UIManager : MonoBehaviour
{
    public static UIManager Instance;

    [Header("Menus")]
    [SerializeField] private GameObject mainMenu;
    public GameObject pauseMenu;
    [SerializeField] private GameObject settingsMenu;

    [Header("Objects")]
    [SerializeField] private CinemachinePanTilt cameraController;
    private MenuState currentMenu;
    private MenuState previousMenu;
    [SerializeField] private Button firstSettingsButton;
    [SerializeField] private Button firstMainButton;

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        if(SceneManager.GetActiveScene().buildIndex == 0) OpenMenu(MenuState.MainMenu);
    }

    public void StartGame()
    {
        Time.timeScale = 1f;
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }

    public void GoMainMenu()
    {
        SceneManager.LoadScene("UIScene");
    }

    public void QuitGame()
    {
        Application.Quit();
    }

    // 🔁 Fonction centrale pour changer de menu
    public void OpenMenu(MenuState newMenu)
    {
        previousMenu = currentMenu;
        currentMenu = newMenu;

        mainMenu.SetActive(newMenu == MenuState.MainMenu);
        pauseMenu.SetActive(newMenu == MenuState.PauseMenu);
        settingsMenu.SetActive(newMenu == MenuState.Settings);
    }

    // 🎮 Bouton Settings (utilisé partout)
    public void OpenSettings()
    {
        OpenMenu(MenuState.Settings);
        Cursor.visible = true;
        firstSettingsButton.Select();
    }

    // 🔙 Bouton retour dans Settings
    public void CloseSettings()
    {
        OpenMenu(previousMenu);
        Cursor.visible = true;
        firstMainButton.Select();
    }

    // ⏸ Exemple pour ouvrir pause menu (ESC)
    public void OpenPauseMenu()
    {
        OpenMenu(MenuState.PauseMenu);
        Cursor.visible = true;
        Time.timeScale = 0f;
        cameraController.enabled = false;
    }

    public void ClosePauseMenu()
    {
        Cursor.visible = false;
        pauseMenu.SetActive(false);
        Time.timeScale = 1f;
        cameraController.enabled = true;
    }
}