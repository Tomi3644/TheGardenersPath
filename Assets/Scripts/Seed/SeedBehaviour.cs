using UnityEngine;

public class SeedBehaviour : MonoBehaviour
{
    void OnCollisionEnter(Collision collision)
    {
        Destroy(gameObject, 0.1f);
    }
}
