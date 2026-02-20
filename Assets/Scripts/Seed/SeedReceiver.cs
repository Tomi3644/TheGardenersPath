using UnityEngine;
using UnityEngine.Events;

public class SeedReceiver : MonoBehaviour
{
    private enum Seeds
    {
        Seed1, Seed2, Seed3, Seed4
    };

    [SerializeField] private Seeds seedToReactTo;
    [SerializeField] private Material fixedMaterial;
    public UnityEvent seedReaction;

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.tag == seedToReactTo.ToString())
        {
            seedReaction.Invoke();
        }
    }

    public void FixObject()
    {
        GetComponent<MeshRenderer>().material = fixedMaterial;
    }

}
