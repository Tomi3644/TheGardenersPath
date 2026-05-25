using UnityEngine;

public class FallingBranchBehaviour : MonoBehaviour
{
    [SerializeField] private GameObject branchObject;
    [SerializeField] private AudioClip fallingBranchSFX;

    void OnTriggerEnter(Collider other)
    {
        if (other.tag == "Player")
        {
            branchObject.SetActive(true);
            SFXManager.instance.PlaySFX(fallingBranchSFX);
        }
    }
}
