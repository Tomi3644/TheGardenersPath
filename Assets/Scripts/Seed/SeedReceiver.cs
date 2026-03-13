using UnityEngine;
using UnityEngine.Events;

public class SeedReceiver : MonoBehaviour
{
    // Script to put in objects that you need to be interactable with a seed

    // This enum contains the seed tag name
    // This will be used to choose which seed should interact with the object
    // and also to check the seed that collided
    private enum Seeds
    {
        MushroomSeed, PlantSeed
    };

    // In this variable, in the inspector, you can set which of the two seeds will invoke the event
    [SerializeField] private Seeds seedToReactTo;
    // This doesn't really matter, it was here to change the material when the seed collided with the right object
    [SerializeField] private Material fixedMaterial;
    // Here is the event that is called
    public UnityEvent seedReaction;

    private void OnCollisionEnter(Collision collision)
    {
        // If the collider has the tag we set in the seedToReactTo variable...
        if (collision.gameObject.tag == seedToReactTo.ToString())
        {
            // ... the event will be called
            seedReaction.Invoke();
        }
    }



    // To add functions to the events, you have two choices :
    // - Make a public function and put it in the inspector (like the one below), it's easier to do but could be harder to debug
    // - Add "seedReaction.AddListener(ScriptWithFunction.FunctionName());" to this script and FunctionName() will be called at every seedReaction call.

    // For now, the second option doesn't make the difference between the two seeds, but if you need that I can implement it (or you can)
    // I think that, for now, the first strategy will work well !
    public void FixObject()
    {
        GetComponent<MeshRenderer>().material = fixedMaterial;
    }

    // HOW TO USE THIS SCRIPT : 
    // - Put it on an object
    // - Choose, in the inspector, the seed that will invoke the event
    // - Add functions/elements to the event.
}
