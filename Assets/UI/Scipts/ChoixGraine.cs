using Microsoft.Unity.VisualStudio.Editor;
using UnityEngine;
using UnityEngine.UI;

public class ChoixGraine : MonoBehaviour
{
    private int graine;
    public GameObject graine1;
    public GameObject graine2;
    public GameObject graine3;
    public GameObject graine4;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        graine = 1;
    }

    private void ChoixTouche()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            graine = 1;
        }
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            graine = 2;
        }
        if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            graine = 3;
        }
        if (Input.GetKeyDown(KeyCode.Alpha4))
        {
            graine = 4;
        }
    }

    private void AffichageGraines()
    {
        graine1.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.white;
        graine2.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.white;
        graine3.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.white;
        graine4.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.white;
        if (graine == 1)
        {
            graine1.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.green;
        }
        if (graine == 2)
        {
            graine2.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.green;        
        }
        if (graine == 3)
        {
            graine3.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.green;
        }
        if (graine == 4)
        {
            graine4.gameObject.GetComponent<UnityEngine.UI.Image>().color = Color.green;
        }
        
    }

    // Update is called once per frame
    void Update()
    {
        ChoixTouche();
        AffichageGraines();
    }
}
