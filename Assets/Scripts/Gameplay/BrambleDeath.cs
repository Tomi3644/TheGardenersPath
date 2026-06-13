using System.Collections;
using UnityEngine;

public class BrambleDeath : MonoBehaviour
{
    public float duration = 1f;

    public void Flatten()
    {
        StartCoroutine(FlattenRoutine());
    }

    private IEnumerator FlattenRoutine()
    {
        Vector3 startScale = transform.localScale;
        Vector3 endScale = new Vector3(
            startScale.x * 1f,
            startScale.y * 0,
            startScale.z * 1f
        );

        float t = 0;

        while (t < duration)
        {
            t += Time.deltaTime;
            transform.localScale = Vector3.Lerp(startScale, endScale, t / duration);
            yield return null;
        }

        gameObject.SetActive(false);
    }
}