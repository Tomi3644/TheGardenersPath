using System;
using Microsoft.Unity.VisualStudio.Editor;
using UnityEngine;
using UnityEngine.UI;

public class SeedChoice : MonoBehaviour
{
    public int seedID = 1;
    public GameObject seedUI1;
    public GameObject seedUI2;
    public GameObject seedUI3;
    public GameObject seedUI4;
    private InputManager inputManager;
    private int currentButton;

    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        inputManager = InputManager.Instance;
    }

    private void InputChoice()
    {
        // Choosing seed using keyboard input
        currentButton = inputManager.PlayerChangedSeedButton();
        if (currentButton != 0)
        {
            seedID = currentButton;
        }

        // Choosing seed using  Wheel scroll
        if (inputManager.PlayerScrolled() < 0f ) // forward
        {
            if(seedID==4){seedID = 1;}
            else{seedID++;}
        }
        else if (inputManager.PlayerScrolled() > 0f ) // backwards
        {
            if(seedID==1){seedID = 4;}
            else{seedID--;}
        }

    }

    private void DisplaySeed()
    {
        // Change seed overlay if choosen
        seedUI1.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.white;
        seedUI2.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.white;
        seedUI3.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.white;
        seedUI4.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.white;
        if (seedID == 1){seedUI1.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.green;}
        if (seedID == 2){seedUI2.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.green;}
        if (seedID == 3){seedUI3.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.green;}
        if (seedID == 4){seedUI4.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.green;}
    }

    // Update is called once per frame
    void Update()
    {
        InputChoice();
        DisplaySeed();
    }
}
