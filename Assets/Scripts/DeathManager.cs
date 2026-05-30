using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Animations;

public class DeathManager : MonoBehaviour
{
    [SerializeField] private GameObject lastRespawnPoint;
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
            lastRespawnPoint = other.gameObject;
        }
        else if (other.tag == "Death")
        {
            Respawn();
        }
    }
    

    private void Respawn()
    {
        capsuleCollider.enabled = false;
        characterController.enabled = false;

        transform.position = lastRespawnPoint.transform.position;

        capsuleCollider.enabled = true;
        characterController.enabled = true;
    }
}
