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
    private string trialstring;
    private string infostring;
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
        //nb that text 2 show 7,8,9,10 corresponds to new conditions:
        // (1,2,3,4 in blocktype) - see trial Params for defn.
        // 1 = slow walk, slow sphere
        // 2 = slow walk, fast sphere
        // 3 = normal walk, slow sphere
        // 4 = normal walk, fast sphere

        infostring = "Pull <any> trigger to begin Trial " + (trialParams.trialD.trialID + 2) + " / " + trialParams.ntrialsperBlock + "\n\n" + // +2 because the trialID is incremented after left click.
                "(Block " + (trialParams.trialD.blockID + 1) + " of " + trialParams.nBlocks + ").";
        
        if (trialParams.trialD.trialID == 19) // hard code 19+2 = trial 1 (not 21 shown to paticipants).
        {
            infostring = "Pull <any> trigger to begin Trial 1 / " + trialParams.ntrialsperBlock + "\n\n" + // +2 because the trialID is incremented after left click.
                "(Block " + (trialParams.trialD.blockID + 1) + " of " + trialParams.nBlocks + ").";
        }

        if (text2show == 0)
        {
            // hide text 
            thestring = ""; // blank
        }
        else if (text2show == 1) // first instructions (stationary practice).
        {
            // update at certain points.
            thestring = "Welcome! \n In this experiment, try your best to keep your Right hand within the sphere. \n" +
                "Let's practice standing still... \n\n " +
                "Pull <any> Trigger to begin practice trials.";
        }
        else if (text2show == 2) // after practice, move to red X
        {
            // update at certain points.
            thestring = "Well done! \n Now, your task is the same, but must be completed while walking." +
                "Please stand on the red X position. \n\n";


        }       
        else if (text2show == 3)
        {
            // standing instructions.
            thestring = "For the next block of trials, \n\n" +
               "the same task must be completed while " +
               " standing still." +
                 " \n\n" +
                  infostring;
        }       
        else if (text2show ==4)
        {
            // standing instructions.
            thestring = "On the next trial, \n\n" +
               "* the walk speed is SLOW, \n\n " +
               " * the target speed is SLOW." +
                 " \n\n" +
                 infostring;

        }
        else if (text2show == 5)
        {
            // standing instructions.
            thestring = "On the next trial, \n\n" +
               "* the walk speed is SLOW, \n\n " +
               " * the target speed is NORMAL." +
                 " \n\n" +
                  "When ready, pull the <any> Trigger to begin";

        }
        else if (text2show == 6)
        {
            // standing instructions.
            thestring = "On the next trial, \n\n" +
               "* the walk speed is NORMAL, \n\n " +
               " * the target speed is SLOW." +
                 " \n\n" +
                  "When ready, pull the <any> Trigger to begin";

        }
        else if (text2show == 7)
        {
            // standing instructions.
            thestring = "On the next trial, \n\n" +
               "* the walk speed is NORMAL, \n\n " +
               " * the target speed is FAST." +
                 " \n\n" +
                  "When ready, pull the <any> Trigger to begin";

        }
        else if (text2show ==87)
        {
            thestring = infostring; // just show info between trials (to track progression).
        }
        else if (text2show == 88)
        {
            thestring = "Experiment over, thank you for your participation";
        }
        thestring.Replace("\\n", "\n");
        textMesh.text = thestring;
    }
}
