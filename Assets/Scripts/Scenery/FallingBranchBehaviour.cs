using System;
using System.Collections;
using System.Linq.Expressions;
using UnityEngine;
using UnityEngine.Playables;

public class FallingBranchBehaviour : MonoBehaviour
{
    [SerializeField] private Animation branchAnim;
    [SerializeField] private AudioClip fallingBranchSFX;
    [SerializeField] private PlayableDirector director;
    [SerializeField] private PlayerController playerController;

    void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            director.Play();
            StartCoroutine(BranchFalling());
        }
    }

    private IEnumerator BranchFalling()
    {
        SFXManager.instance.walking = false;
        playerController.enabled = false;
        yield return new WaitForSeconds(1f);
        SFXManager.instance.PlaySFX(fallingBranchSFX);
        branchAnim.Play();
        yield return new WaitForSeconds(3.5f);
        playerController.enabled = true;
    }
}
