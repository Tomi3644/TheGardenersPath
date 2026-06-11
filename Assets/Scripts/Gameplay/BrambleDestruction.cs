using UnityEngine;

public class BrambleDestruction : MonoBehaviour
{
    public Animator animator;

    public void OnHitBySeed()
    {
        animator.SetTrigger("Disappear");
    }

    // appelée à la fin de l'animation via Animation Event
    public void DisableObject()
    {
        gameObject.SetActive(false);
    }
}