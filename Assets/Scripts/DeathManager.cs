using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations;

public class DeathManager : MonoBehaviour
{
    [SerializeField] private List<GameObject> respawnPoints = new List<GameObject>();
    private CapsuleCollider capsuleCollider;
    private CharacterController characterController;

    void Start()
    {
        capsuleCollider = GetComponent<CapsuleCollider>();
        characterController = GetComponent<CharacterController>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Respawn")
        {
            bool isSaved = false;
            foreach (GameObject point in respawnPoints)
            {
                if (point == other)
                {
                    isSaved = true;
                }
            }
            if (!isSaved)
            {
                respawnPoints.Add(other.gameObject);
            }
        }
        else if (other.tag == "Death")
        {
            Respawn();
        }
    }
    

    private void Respawn()
    {
        GameObject closestObject = null;
        float minDist = Mathf.Infinity;
        Vector3 currentPos = transform.position;
        foreach (GameObject point in respawnPoints)
        {
            float dist = Vector3.Distance(point.transform.position, currentPos);
            if (dist < minDist)
            {
                minDist = dist;
                closestObject = point;
            }
        }
        capsuleCollider.enabled = false;
        characterController.enabled = false;

        transform.position = closestObject.transform.position;

        capsuleCollider.enabled = true;
        characterController.enabled = true;
    }
}
