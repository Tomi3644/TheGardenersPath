using UnityEngine;
using System;
using System.IO;

public class Screenshot : MonoBehaviour
{
    [SerializeField]
    [Range(1, 5)]
    private int size = 1;

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.P))
        {
            string picturesPath = Environment.GetFolderPath(
                Environment.SpecialFolder.MyPictures);

            string screenshotFolder = Path.Combine(
                picturesPath,
                "Gardener's Path");

            Directory.CreateDirectory(screenshotFolder);

            string fileName = $"screenshot_{Guid.NewGuid()}.png";

            string fullPath = Path.Combine(
                screenshotFolder,
                fileName);

            ScreenCapture.CaptureScreenshot(fullPath, size);

            Debug.Log("Capture sauvegardée : " + fullPath);
        }
    }
}