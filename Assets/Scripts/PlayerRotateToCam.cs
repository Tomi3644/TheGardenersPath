using UnityEngine;

public class PlayerRotateToCam : MonoBehaviour
{

    private Transform cameraTransform;

    void Start()
    {
        cameraTransform = Camera.main.transform;
    }

    // Update is called once per frame
    void Update()
    {
        transform.rotation = Quaternion.Euler(transform.eulerAngles.x, cameraTransform.eulerAngles.y, transform.eulerAngles.z);
    }
}
