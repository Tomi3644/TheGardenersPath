using System;
using System.Collections;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.Playables;

public class CreditsTransitioning : MonoBehaviour
{
    [SerializeField] private float waitDuration;
    [SerializeField] private PlayableDirector director;
    void Awake()
    {
        DontDestroyOnLoad(this);
        GetComponent<AudioSource>().Play();
        StartCoroutine(SceneTransition());
        director.Play();
    }

    private IEnumerator SceneTransition()
    {
        yield return new WaitForSeconds(waitDuration);
        SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex + 1);
    }
}
