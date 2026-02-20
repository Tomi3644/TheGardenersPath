using UnityEngine;
using UnityEngine.UI;

public class GameManager : MonoBehaviour
{
    [SerializeField] private Slider progressSlider;
    [SerializeField] private int interactionsNeeded;
    [SerializeField] private GameObject endGameMenu;
    private int interactionCounter;

    void Start()
    {
        progressSlider.maxValue = interactionsNeeded;
    }
    public void SeedInteracted()
    {
        interactionCounter++;
        progressSlider.value = interactionCounter;
        if (interactionCounter >= interactionsNeeded)
        {
            endGameMenu.SetActive(true);
        }
    }
}
