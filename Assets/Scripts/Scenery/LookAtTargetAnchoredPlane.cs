using UnityEngine;

public class LookAtTargetAnchoredPlane : MonoBehaviour
{
    private Transform target;

    void Awake()
    {
        target = Camera.main.transform;
    }

    void Update()
    {
        if (target != null)
        {
            Vector3 direction = target.position - transform.position;
            direction.y = 0f;

            Quaternion lookRotation = Quaternion.LookRotation(-direction);

            // Correction pour l'orientation du Plane
            transform.rotation = lookRotation * Quaternion.Euler(90f, 0f, 0f);
        }
    }
}