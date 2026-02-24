using System;
using UnityEngine;

public class LookAtTarget : MonoBehaviour
{
    private Transform target;

    void Awake()
    {
        // Every objects affected by LookatTarget look at the camera
        target = Camera.main.transform;
    }

    void Update()
    {
        if(target != null)
        {
            // Inverted direction for the quads
            Vector3 direction = target.position - transform.position;
            transform.rotation = Quaternion.LookRotation(-direction);
        }
    }
}
