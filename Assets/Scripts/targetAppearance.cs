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

    // Colours to use that indicate next trial type (just show walk speed)
   
    public Color myRand1 = new Color(0.2f, 0.2f, 1f); //slow (blue)
    public Color myRand2 = new Color(0.8f, 0.8f, .2f); //normal pace (yellow)

    trialParameters trialParams;
    Renderer rend;
    runExperiment runExp;
    private Color targColor;

    void Start()
    {
        rend = GetComponent<Renderer>();
        // store initial colour
        targColor = rend.material.color; // 
                                         // note that the method below, updates the targ colour.

        trialParams = GameObject.Find("scriptHolder").GetComponent<trialParameters>();

        runExp = GameObject.Find("scriptHolder").GetComponent<runExperiment>();
    }

    // Change on trigger.

    private void OnTriggerEnter(Collider other)
    {
        // change colour
        if (runExp.trialinProgress) // keep trialtype colour before we begin walking.
        {
            rend.material.SetColor("_Color", myGreen);

        }
        
    }
    private void OnTriggerExit(Collider other)
    {
        // change colour back to original
        if (runExp.trialinProgress)
        {
            rend.material.SetColor("_Color", myRed);
        }
    }

    // color change method.
    public void setColour(Color newCol)
    {
        // because we are changing the sphere shaders colour, keep the alpha.
        //print("New Color: " + newCol);
        rend.material.SetColor("_Color", newCol);


    }
    public void setPreTrialColour(int trialcount)
    {
        int btype = trialParams.blockTypeArray[trialcount, 2];

       

        Color useCol = targColor;
        // switch colour of pretrial sphere, based on next trial parameters:
        string ttype = "";

        if (btype == 1) { useCol = myRand1; ttype = "slow walk, norm target"; }
        else if (btype == 2) { useCol = myRand1; ttype = "slow walk, fast target"; }
        else if (btype == 3) { useCol = myRand2; ttype = "norm walk, norm target"; }
        else if (btype == 4) { useCol = myRand2; ttype = "norm walk, fast target"; }

        print("also changing pretrial colour to type " + btype + ", " + ttype);
        setColour(useCol); // indicates ready for click to begin trial

    }
}

