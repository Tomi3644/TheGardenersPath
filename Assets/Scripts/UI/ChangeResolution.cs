using UnityEngine;
using TMPro;
using UnityEngine.UI;

// To add more resolution make the following steps

// In ChooseResolution :
// Change (resolutionChoice == 0) { resolutionChoice = NUMBER; } to if (resolutionChoice == 0) { resolutionChoice = NUMBER+1; }
// Change (resolutionChoice == NUMBER) { resolutionChoice = 1; } to if (resolutionChoice == NUMBER+1) { resolutionChoice = 1; }

// In DisplayResolution :
// Add if (resolutionChoice == NUMBER) {
//          resolution.text = "Your resolution";
//          SetResolution(int width, int height, fullscreen);


public class ChangeResolution : MonoBehaviour
{
    private int resolutionChoice;
    private bool fullScreen;
    [SerializeField] private TextMeshProUGUI resolution;
    [SerializeField] private TextMeshProUGUI fullScreenDisplay;
    [SerializeField] private Button buttonLeft;
    [SerializeField] private Button buttonRight;
    [SerializeField] private Button buttonFullScreen;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        resolutionChoice = 1;
        resolution.text = "1920x1080";
        fullScreen = true;
        // Adding Listeners so we know when a button is pressed
        buttonLeft.onClick.AddListener(() => resolutionChoice--);
        buttonRight.onClick.AddListener(() => resolutionChoice++);
        buttonFullScreen.onClick.AddListener(() => fullScreen = !fullScreen);
    }

    // Update is called once per frame
    void Update()
    {
        ChooseResolution();
        DisplayResolution();
    }

    void ChooseResolution()
    {
        // Avoid int out of range
        if (resolutionChoice == 0) { resolutionChoice = 3; }
        if (resolutionChoice == 4) { resolutionChoice = 1; }
    }

    void DisplayResolution()
    {
        // Display FullScreen
        if (fullScreen) fullScreenDisplay.text = "FullScreen : ON";
        else fullScreenDisplay.text = "FullScreen : OFF";

        // Display the selected resolution
        if (resolutionChoice == 1)
        {
            resolution.text = "1366x768";
            Screen.SetResolution(1366, 768, fullScreen);
        }
        if (resolutionChoice == 2)
        {
            resolution.text = "1600x900";
            Screen.SetResolution(1600, 900, fullScreen);
        }
        if (resolutionChoice == 3)
        {
            resolution.text = "1920x1080";
            Screen.SetResolution(1920, 1080, fullScreen);
        }
    }
}
