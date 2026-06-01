using System.Collections;
using UnityEngine;

public class CaveLightFader : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Cave")
        {
            StartCoroutine(FadeIntensity(1f, 0f, 3f));
        }
    }
    private void OnTriggerExit(Collider other)
    {
        if (other.tag == "Cave")
        {
            StartCoroutine(FadeIntensity(0f, 1f, 3f));
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
