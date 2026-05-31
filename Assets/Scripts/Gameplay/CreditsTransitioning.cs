using System;
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;

public class CreditsTransitioning : MonoBehaviour
{
    [SerializeField] private float waitDuration;
    void Awake()
    {
        DontDestroyOnLoad(this);
        GetComponent<AudioSource>().Play();
        StartCoroutine(SceneTransition());
    }

    private IEnumerator SceneTransition()
    {
        yield return new WaitForSeconds(waitDuration);
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }
}
