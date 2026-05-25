using System;
using System.Collections;
using System.Linq.Expressions;
using UnityEngine;

public class SFXManager : MonoBehaviour
{
    public static SFXManager instance;
    [SerializeField] private AudioSource normalSource;
    [SerializeField] private AudioSource movementSource;
    public AudioClip seedReceivedSFX;
    [SerializeField] private AudioClip footstepsSFX;
    [SerializeField] private AudioClip climbingSFX;
    [SerializeField] private float timeBetweenSFX;
    public bool walking, climbing, footstepsCoroutineStarted, climbingCoroutineStarted;

    void Awake()
    {
        instance = this;
    }

    public void PlaySFX(AudioClip clip)
    {
        normalSource.PlayOneShot(clip);
    }
    private void PlayMovementSFX(AudioClip clip)
    {
        movementSource.volume = UnityEngine.Random.Range(0.7f, 8f);
        movementSource.pitch = UnityEngine.Random.Range(0.8f, 1.2f);
        movementSource.PlayOneShot(clip);
    }

    public IEnumerator FootstepsSFX()
    {
        footstepsCoroutineStarted = true;
        while (walking)
        {
            PlayMovementSFX(footstepsSFX);
            yield return new WaitForSeconds(timeBetweenSFX);
        }
        footstepsCoroutineStarted = false;
    }
    public IEnumerator ClimbingSFX()
    {
        climbingCoroutineStarted = true;
        while (climbing)
        {
            PlayMovementSFX(climbingSFX);
            yield return new WaitForSeconds(timeBetweenSFX);
        }
        climbingCoroutineStarted = false;
    }
}
