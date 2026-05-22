using UnityEngine;

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
    [SerializeField] private GameObject pauseMenu;
    [SerializeField] private GameObject settingsMenu;

    private MenuState currentMenu;
    private MenuState previousMenu;

    private void Awake()
    {
        Instance = this;
    }

    private void Start()
    {
        OpenMenu(MenuState.MainMenu);
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
    }

    // 🔙 Bouton retour dans Settings
    public void CloseSettings()
    {
        OpenMenu(previousMenu);
    }

    // ⏸ Exemple pour ouvrir pause menu (ESC)
    public void OpenPauseMenu()
    {
        OpenMenu(MenuState.PauseMenu);
        Cursor.visible = true;
        Time.timeScale = 0f;
    }

    public void ClosePauseMenu()
    {
        Cursor.visible = false;
        OpenMenu(MenuState.MainMenu);
        Time.timeScale = 1f;
    }
}