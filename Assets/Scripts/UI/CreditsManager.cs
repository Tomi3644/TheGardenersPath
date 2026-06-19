using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class CreditsManager : MonoBehaviour
{
    [SerializeField] private List<string> displayElements;
    [SerializeField] private float transitionTime;
    [SerializeField] private TMP_Text creditsText;
    private int index = 0;

    void Start()
    {
        StartCoroutine(Credits());
    }

    private IEnumerator Credits()
    {
        while (index < displayElements.Count)
        {
            creditsText.text = displayElements[index];
            yield return new WaitForSeconds(transitionTime);
            index++;
        }
        Destroy(FindFirstObjectByType<CreditsTransitioning>().gameObject);
        Cursor.visible = true;
        SceneManager.LoadScene(0);
    }

    private void Update()
    {
        if (InputManager.Instance.OpeningSettingsMenu())
        {
            StopCoroutine(Credits());
            Destroy(FindFirstObjectByType<CreditsTransitioning>().gameObject);
            Cursor.visible = true;
            SceneManager.LoadScene(0);
        }
    }
}
