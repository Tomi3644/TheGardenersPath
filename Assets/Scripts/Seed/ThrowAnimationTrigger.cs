using UnityEngine;

public class ThrowAnimationTrigger : MonoBehaviour
{
    [SerializeField] private SeedThrower seedThrower;

    public void OnThrowFrameAnim(int ID)
    {
        seedThrower.Throw(ID);
    }
}
