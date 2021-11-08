using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class targetAppearance : MonoBehaviour
{
    // Update the colour of the target based on relative hand position.
    // if hand is within sphere collider, colour change.
    // Start is called before the first frame update

    // create an RGB colour for target entered (Oncollision)
    Color myGreen = new Color(.02f, .91f, .1f); // bright green
    Color myRed = new Color(.91f, .02f, .1f); // bright red

    Renderer rend;
    private Color targColor;
    void Start()
    {
        rend = GetComponent<Renderer>();
        // store initial colour
        targColor = rend.material.color;
        Debug.Log("Color is " + targColor);
    }

    // Update is called once per frame

    private void OnTriggerEnter(Collider other)
    {
        // change colour
        rend.material.SetColor("_Color", myGreen);
    }
    private void OnTriggerExit(Collider other)
    {
        // change colour back to original
        rend.material.SetColor("_Color", myRed);
    }

    // color change method.
    public void setColour(Color newCol)
    {
        // because we are changing the sphere shaders colour, keep the alpha.
        //print("New Color: " + newCol);
        rend.material.SetColor("_Color", newCol);


    }
}

