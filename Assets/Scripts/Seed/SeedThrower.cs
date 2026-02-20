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

    private bool readyToThrow;
    private InputManager inputManager;
    private SeedChoice seedChoice;

    private void Start()
    {
        readyToThrow = true;
        inputManager = InputManager.Instance;
        seedChoice = FindAnyObjectByType<SeedChoice>();
    }

    private void Update()
    {
        if(inputManager.PlayerThrewThisFrame() && readyToThrow)
        {
            Throw();
        }
    }

    private void Throw()
    {
        readyToThrow = false;

        // instantiate object to throw
        GameObject projectile = Instantiate(seedPrefabs[seedChoice.seedID - 1], attackPoint.position, cam.rotation);

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
}
