using UnityEngine;

public class SeedThrower : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Transform cam;
    [SerializeField] private Transform plantStartPos, mushroomStartPos;
    [SerializeField] private GameObject objectToThrow;
    [SerializeField] private Animator handsAnimator;
    [SerializeField] private Animator seedGetUIAnimator;
    [SerializeField] private GameObject seedEntryCollider;

    [Header("Settings")]
    [SerializeField] private float throwCooldown;

    [Header("Throwing")]
    [SerializeField] private float throwForce;
    [SerializeField] private float throwUpwardForce;

    [Header("Seed Prefabs")]
    [SerializeField] private GameObject[] seedPrefabs;

    [Header("Seed Sound")]
    [SerializeField] private MusicTransitions transition;
    [SerializeField] private AudioClip throwAudio;
    [SerializeField] private AudioClip seedGet;


    private bool plantSeedUnlocked;
    private int seedThrownID;
    private Transform attackPoint;

    private bool readyToThrow;
    private bool alreadyThrewPlant;
    private InputManager inputManager;

    private void Start()
    {
        readyToThrow = true;
        inputManager = InputManager.Instance;
    }

    private void Update()
    {
        seedThrownID = inputManager.PlayerThrewSeed();
        if (seedThrownID != 0 && readyToThrow)
        {
            if (seedThrownID == 2)
            {
                if (plantSeedUnlocked)
                {
                    if (!alreadyThrewPlant)
                    {
                        alreadyThrewPlant = true;
                        seedGetUIAnimator.SetTrigger("Threw");
                    }
                    PlayThrowAnimation();
                }
            }
            else PlayThrowAnimation();
        }
    }

    private void PlayThrowAnimation()
    {
        switch (seedThrownID)
        {
            case 1:
                handsAnimator.SetTrigger("Mushroom");
                break;
            case 2:
                handsAnimator.SetTrigger("Plant");
                break;
            default:
                break;
        }
    }
    

    public void Throw(int seedID)
    {
        readyToThrow = false;

        if (seedID == 1) attackPoint = mushroomStartPos;
        else attackPoint = plantStartPos;

        // instantiate object to throw
        Vector3 spawnPos = attackPoint.position + cam.forward * 0.5f;

        GameObject projectile = Instantiate(
            seedPrefabs[seedID - 1],
            spawnPos,
            cam.rotation
        );

        // get rigidbody component
        Rigidbody projectileRb = projectile.GetComponent<Rigidbody>();

        // calculate direction
        Vector3 forceDirection = cam.transform.forward;

        RaycastHit hit;

        if(Physics.Raycast(cam.position, cam.forward, out hit, 500f, Physics.DefaultRaycastLayers, QueryTriggerInteraction.Ignore))
        {
            forceDirection = (hit.point - attackPoint.position).normalized;
        }

        // add force
        Vector3 forceToAdd = forceDirection * throwForce + transform.up * throwUpwardForce;

        projectileRb.AddForce(forceToAdd, ForceMode.Impulse);
        SFXManager.instance.PlaySFX(throwAudio);

        // implement throwCooldown
        Invoke(nameof(ResetThrow), throwCooldown);
    }

    private void ResetThrow()
    {
        readyToThrow = true;
    }

    void OnTriggerEnter(Collider other)
    {
        if (other.tag == "PlantSeedGet")
        {
            seedEntryCollider.SetActive(false);
            plantSeedUnlocked = true;
            SFXManager.instance.PlaySFX(seedGet);
            transition.MakeTransition();
            Destroy(other.gameObject);
            seedGetUIAnimator.gameObject.SetActive(true);
        }
    }
}
