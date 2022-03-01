using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class showText : MonoBehaviour
{
    // this script is used as a method, called from runExperiment.

    private TextMeshProUGUI textMesh;
    runExperiment runExperiment;
    trialParameters trialParams;
    private string thestring;
    // Start is called before the first frame update
    void Start()
    {
        textMesh = gameObject.GetComponent<TextMeshProUGUI>();
        runExperiment = GameObject.Find("scriptHolder").GetComponent<runExperiment>();
        trialParams = GameObject.Find("scriptHolder").GetComponent<trialParameters>();
    }

    //
    public void updateText(int text2show)
    {
        if (text2show == 0)
        {
            // hide text 
            thestring = ""; // blank
        }
        else if (text2show == 1)
        {
            // update at certain points.
            thestring = "Welcome! \n In this experiment, try your best to keep your Right hand within the sphere. \n" +
                "Let's practice standing still... \n\n " +
                "Pull the <left> Trigger to begin practice trials.";
        }
        else if (text2show == 2)
        {
            // update at certain points.
            thestring = "Well done! \n Now, your task is the same, but must be completed while walking." +
                "Align your back to the edge of the room. \n\n When ready, pull the <left> Trigger to begin. Get ready to follow the arrow!";
        }
        else if (text2show ==3) // between trials.
        {
           
            thestring = "Pull the <left> trigger to begin Trial " + (runExperiment.TrialCount +1) + " / " + trialParams.nTrials; ;
        }
        thestring.Replace("\\n", "\n");
        textMesh.text = thestring;
    }
}
