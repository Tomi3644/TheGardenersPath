using UnityEngine;

public class SeedThrower : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private Transform cam;
    [SerializeField] private Transform attackPoint;
    [SerializeField] private GameObject objectToThrow;

    [Header("Settings")]
    [SerializeField] private float throwCooldown;

    [Header("Throwing")]
    [SerializeField] private float throwForce;
    [SerializeField] private float throwUpwardForce;

    [Header("Seed Prefabs")]
    [SerializeField] private GameObject[] seedPrefabs;

    private bool plantSeedUnlocked;
    private int seedThrownID;

    private bool readyToThrow;
    private InputManager inputManager;

    private void Start()
    {
        readyToThrow = true;
        inputManager = InputManager.Instance;
    }

    private void Update()
    {
        seedThrownID = inputManager.PlayerThrewSeed();
        if(seedThrownID != 0 && readyToThrow)
        {
            if (seedThrownID == 2)
            {
                if (plantSeedUnlocked)
                {
                    Throw(seedThrownID);
                }
            }
            else Throw(seedThrownID);
        }
    }

    private void Throw(int seedID)
    {
        readyToThrow = false;

        // instantiate object to throw
        GameObject projectile = Instantiate(seedPrefabs[seedID - 1], attackPoint.position, cam.rotation);

        // get rigidbody component
        Rigidbody projectileRb = projectile.GetComponent<Rigidbody>();

        // calculate direction
        Vector3 forceDirection = cam.transform.forward;

        RaycastHit hit;

        if(Physics.Raycast(cam.position, cam.forward, out hit, 500f))
        {
            forceDirection = (hit.point - attackPoint.position).normalized;
        }

        // add force
        Vector3 forceToAdd = forceDirection * throwForce + transform.up * throwUpwardForce;

        projectileRb.AddForce(forceToAdd, ForceMode.Impulse);

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
            plantSeedUnlocked = true;
            Destroy(other.gameObject);
        }
    }
}
