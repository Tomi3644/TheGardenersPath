using System.Collections;
using UnityEngine;

public class CaveLightFader : MonoBehaviour
{
    [SerializeField] private float fadeTime;
    [SerializeField] private DeathManager deathManager;
    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Cave" && deathManager.hasRespawnedThisFrame == false)
        {
            StartCoroutine(FadeIntensity(1f, 0f, fadeTime));
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Cave")
        {
            StartCoroutine(FadeIntensity(0f, 1f, fadeTime));
        }
    }

    public IEnumerator FadeIntensity(float startIntensity, float targetIntensity, float timeToFade)
    {
        float elapsedTime = 0;

        while (elapsedTime < timeToFade)
        {
            elapsedTime += Time.deltaTime;
            RenderSettings.ambientIntensity = Mathf.Lerp(startIntensity, targetIntensity, elapsedTime / timeToFade);
            yield return null;
        }
        yield break;
    }
}
