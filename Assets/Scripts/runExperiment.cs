using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.InputSystem;

/// <summary>
///  Manual tracking task.
/// </summary>
public class runExperiment : MonoBehaviour
{
    /// <summary>
    /// /// Imports parameters and handles the flow of the experiment.
    /// e.g. Trial progression, listeners etc.
    /// /// </summary>/// 
    
    // basic experiment structure
    public string participant;
    public int TrialCount; //walk trajectories
    public int TrialType;  // speed/walk combo
    public bool isPractice=true; // determines walking guide motion (stationary during practice).
    public bool isStationary = true; 
    // flow managers
    public bool trialinProgress; // handles current state within experiment 
    private bool SetUpSession; // for alignment of walking space.
    private int usematerial;  // change walk image (stop sign and arrows).
    public bool updateText;
    private bool setXpos;

    // passed to other scripts (couroutine, record data etc).
    public float trialTime; // clock within trial time, for RT analysis.
    public bool collectTrialSummary; //passed to record data (simply trial and block info).
    

    // speak to.
   
    ViveInput viveInput;
    recordData recordData;
    //Staircase ppantStaircase;
    randomWalk randomWalk;
    walkParameters motionParams;
    walkingGuide walkingGuide;
    trialParameters trialParams;
    showText showText;
    changeDirectionMaterial changeMat;
    targetAppearance targetAppearance; // targetAppearance in this script,
                                       // is simply a colour change to denote trial type.

    // declare public GObjs.
    public GameObject hmd;
    public GameObject effector;
    public GameObject SphereShader;
    GameObject redX;
    void Start()
    {
        // dependencies
        targetAppearance = GameObject.Find("Sphere").GetComponent<targetAppearance>();
        viveInput =GetComponent<ViveInput>();
        recordData = GetComponent<recordData>();
        randomWalk = GetComponent<randomWalk>();
        motionParams =GetComponent<walkParameters>();
        walkingGuide = GetComponent<walkingGuide>();
        trialParams = GetComponent<trialParameters>();

        showText = GameObject.Find("Instructions (TMP)").GetComponent<showText>();
        changeMat = GameObject.Find("directionCanvas").GetComponent<changeDirectionMaterial>();
        redX = GameObject.Find("RedX");

        //flow managers
        TrialCount = 0;
       
        trialinProgress = false;
        SetUpSession = true;
        usematerial = 0; // 0=show stop sign, later changed to arrows for walk guide.

        changeMat.update(0); // render stop sign
        showText.updateText(1); // pre trial exp instructions


        print("setting up ... Press <space>  or <click> to confirm origin location");
    }


    private void Update()
    {

        // set up origin.
        if (SetUpSession)
        {

            CalibrateStartPos(); // align motion origin to player.
            

            //targetAppearance.setColour(ppantStaircase.preTrialColor); // indicates ready for click to begin trial
           
        }


        // don't access every frame, but flag is toggled at end of blocks.
        if (updateText) // 
        {
            determineText(); // method called to determine instructions shown.
            updateText = false; // 
        }


        // check for startbuttons, but only if not in trial.
        if (!trialinProgress && !setXpos && viveInput.clickLeft && TrialCount < trialParams.nTrials)
        {
            startTrial(); // starts coroutine, changes listeners, presets staircase.            
        }


        // increment within trial time.
        if (trialinProgress)
        {
            trialTime += Time.deltaTime;
            //print("Trial Time: " + trialTime);
        }

        if (!SetUpSession && trialTime == 0 && !trialinProgress)
        {
           
            showText.updateText(3); // Trial count.
           
        }

        // increment within trial time.
        if (trialinProgress)
        {
            trialTime += Time.deltaTime;
            //print("Trial Time: " + trialTime);
        }


        // check for trial end.
        if (trialinProgress && (trialTime >= motionParams.walkDuration)) // use duration (rather than distance), to account for stationary trials.
        {

            trialPackdown();

            TrialCount++;
        }


        //check for block end.
        if (setXpos)
        {

        }


            
        if (TrialCount == trialParams.nTrials)
        {
            print("Experiment Over");
            targetAppearance.setColour(new Color(1, 0, 0));
            showText.updateText(4); // post exp 

        }
           
        
    }

    /// 
    /// ////////////////////////////////////////
    /// RUN EXPERIMEN METHODS:
    /// //////////////////////////////////////////
    /// 

    // cleaning up the Update() function. 
    void CalibrateStartPos()
    {

        GameObject motionOrigin = GameObject.Find("motionOrigin");
        Vector3 environmentPosition = motionOrigin.transform.position;
        Vector3 headPosition = hmd.transform.position;

        // because we start Motion path in the middle, offset this to reposition at HMD.
        environmentPosition.x = headPosition.x  - motionParams.guideDistance; // - stimParams.guideDistance;
        environmentPosition.z = headPosition.z;

        motionOrigin.transform.position = environmentPosition;


        // check for key press to confirm new position.
        if (Keyboard.current.spaceKey.wasPressedThisFrame || viveInput.clickState)
        {
            
            print("Location confirmed, beginning experiment");

            SetUpSession = false;
            walkingGuide.fillStartPos(); // update start pos in WG.
        }
       
       
    }


    private void startTrial()
    {

        // clear previous trial info, reset, and assign from preallocated variables:
        trialinProgress = true; // for coroutine (handled in targetAppearance.cs).        
        showText.updateText(0); // remove text
                                //  // set redX to hidden:

        redX.SetActive(false);
        trialTime = 0;  // clock accurate reacton time from time start      

        // Establish (this) trial parameters:
        TrialType = trialParams.blockTypeArray[TrialCount, 2];

        float mvmnt = trialParams.blockTypeArray[TrialCount, 2];
        // query if stationary or not.
        isStationary = mvmnt == 0 ? true : false; // 1 and 2 (in mvmnt) corresponds to stationary or moving)

        // add to trialD for recordData.cs
        trialParams.trialD.trialNumber = TrialCount;
        trialParams.trialD.blockID = trialParams.blockTypeArray[TrialCount, 0];
        trialParams.trialD.trialID = trialParams.blockTypeArray[TrialCount, 1];
        trialParams.trialD.trialID = TrialType;
        //trialParams.trialD.trialType = //TrialType;

        //store bool as int
        float fStat = isStationary ? 1 : 0;
        trialParams.trialD.isStationary = fStat;


        randomWalk.transform.localPosition = motionParams.cubeOrigin;
        randomWalk.origin = motionParams.cubeOrigin;
        motionParams.lowerBoundaries = motionParams.cubeOrigin - motionParams.cubeDimensions;
        motionParams.upperBoundaries = motionParams.cubeOrigin + motionParams.cubeDimensions;

        randomWalk.lowerBoundaries = motionParams.lowerBoundaries;
        randomWalk.upperBoundaries = motionParams.upperBoundaries;
        randomWalk.stepDurationRange = motionParams.stepDurationRange;
        // can't use   = stepDistanceRange; as the string is rounded to 1f precision.
        // so access the dimensions directly:
        randomWalk.stepDistanceRange.x = motionParams.stepDistanceRange.x;
        randomWalk.stepDistanceRange.y = motionParams.stepDistanceRange.y;

        // set fields in randomWalk and recordData to begin exp:
        randomWalk.walk = randomWalk.phase.start;
        recordData.recordPhase = recordData.phase.collectResponse;
        walkingGuide.walkMotion = walkingGuide.motion.start;
        walkingGuide.returnRotation = walkingGuide.motion.idle;



        // define if walk/stationary based on trial ID: (i.e. if within practice blocks)
        if (trialParams.blockTypeArray[TrialCount, 0] < trialParams.nStaircaseBlocks)
        //if (TrialCount <= (nStaircaseTrials - 1))
        {
            // set for outside(randomWalk) listeners. When practice, motion guide is stationary.
            isPractice = true;
            changeMat.update(usematerial); // Render green arrow or stop.
        }
        else
        {
            isPractice = false;

            changeMat.update(usematerial); //usematerial determined by text instructions (stop or go arrow).
        }




        //start coroutine to control target onset and target behaviour:
        print("Starting Trial " + (TrialCount + 1) + " of " + trialParams.nTrials + ". Type: " + TrialType );
        
    }

    // based on various listeners, and experiment position, determine which text to show (or hide) from
    // the participant.
    public void determineText()
    {

        if (trialParams.trialD.trialID == trialParams.ntrialsperBlock - 1)
        {

            // stationary or not on the next block?

            float mvmnt = trialParams.blockTypeArray[TrialCount + 1, 2];
            // query if stationary or not.
            isStationary = mvmnt == 0 ? true : false;

            if (isStationary)
            {
                showText.updateText(5);
                usematerial = 0;
                changeMat.update(0); // Render green arrow.
            }
            else
            {
                showText.updateText(6);
                usematerial = 1; //green arrow.
                changeMat.update(usematerial); // Render green arrow.
            }


            setXpos = true;
        }
        else if (trialParams.trialD.trialID > 0)
        {
            showText.updateText(3); // show Trial count between trials.
            setXpos = false;
        }




    }

    void trialPackdown()
    {
        trialinProgress = false;
        trialTime = 0;

        // safety, these should already have been stopped in walkingGuide
        randomWalk.walk = randomWalk.phase.stop;
        recordData.recordPhase = recordData.phase.stop;
        // also stop guide, and start return rotation
        walkingGuide.walkMotion = walkingGuide.motion.idle;

        walkingGuide.returnRotation = walkingGuide.motion.start;


        walkingGuide.returnRotation = walkingGuide.motion.start;
        print("End of Trial " + (TrialCount + 1));


        recordData.collectTrialSummary(); // appends information to text file.
       



        targetAppearance.setColour(trialParams.preTrialColor); // indicates ready for click to begin trial

        // write trial summary to text file (in debugging).
        //recordData.writeTrialSummary(); // writes text to csv after each trial.


        // if last trial of the block, prepare the placement of intructions / start pos./

        if (trialParams.trialD.trialID == trialParams.ntrialsperBlock - 1)
        {
            setXpos = true; // also signifies block end.

            // SET SPEED  next block.
            motionParams.setPathDuration(TrialType);
            
        }
        updateText = true; // show text between trials, at .


        // set redX to active:
        redX.SetActive(true);
    }

}

