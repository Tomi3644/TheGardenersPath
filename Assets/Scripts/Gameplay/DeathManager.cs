using System.Collections;
using System.Collections.Generic;
using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.Animations;
using UnityEngine.InputSystem;

public class DeathManager : MonoBehaviour
{
    [SerializeField] private GameObject lastRespawnPoint;
    private CapsuleCollider capsuleCollider;
    private CharacterController characterController;
    public bool hasRespawnedThisFrame;

    [Header("Death Triggers")]
    [SerializeField] private SeedThrower seedThrower;
    [SerializeField] private PlayerInput playerInput;
    [SerializeField] private PlayerController playerController;
    [SerializeField] private Animation deathUI;

    [Header("SFX")]
    [SerializeField] private AudioClip riverDeath;
    [SerializeField] private AudioClip fallDeath;
    


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
            if (other.gameObject.layer == 4) // Layer 4 = Water
            {
                SFXManager.instance.PlaySFX(riverDeath);
            }
            else
            {
                SFXManager.instance.PlaySFX(fallDeath);
            }
            StartCoroutine(SoundTimer());
        }
    }
    
    private IEnumerator SoundTimer()
    {
        seedThrower.enabled = false;
        playerInput.enabled = false;
        playerController.enabled = false;
        deathUI.gameObject.SetActive(true);
        deathUI.Play();

        yield return new WaitForSeconds(2f);

        seedThrower.enabled = true;
        playerInput.enabled = true;
        playerController.enabled = true;
        deathUI.gameObject.SetActive(false);

        Respawn();
    }

    private void Respawn()
    {
        capsuleCollider.enabled = false;
        characterController.enabled = false;

        transform.position = lastRespawnPoint.transform.position;
        hasRespawnedThisFrame = true;

        capsuleCollider.enabled = true;
        characterController.enabled = true;
        StartCoroutine(RespawnVarReset());
    }

    private IEnumerator RespawnVarReset()
    {
        yield return new WaitForSeconds(0.5f);
        hasRespawnedThisFrame = false;
    }
}
