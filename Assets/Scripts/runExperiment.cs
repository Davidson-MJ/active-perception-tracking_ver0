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
    
    // basic experiment structure, params to be viewed in inspector:
    public string participant;
    public int TrialCount; //walk trajectories
    public int TrialType;  // speed/walk combo
    public bool isPractice=true; // determines walking guide motion (stationary during practice).
    public bool isStationary = false; 
  
    // flow managers (i.e. flags to control experiment presentation)
   
    public bool trialinProgress; // handles current state within experiment 
    private bool SetUpSession; // for alignment of walking space.
    private int usematerial;  // change walk image (stop sign or arrows).
    public bool updateText; // when to prepare the next set of instructions
    private bool setXpos; // when to recalibrate start position (between blocks)

    // passed to other scripts (couroutine, record data etc).
    public float trialTime; // clock within trial time, for RT analysis.
    public bool collectTrialSummary; //passed to record data (simply trial and block info).
    

    // speak to various scripts/ gameobjects:
   
    ViveInput viveInput;
    recordData recordData;
    randomWalk randomWalk;
    walkParameters walkParams;
    walkingGuide walkingGuide;
    trialParameters trialParams;
    showText showText;
    changeDirectionMaterial changeMat;
    targetAppearance targetAppearance; // targetAppearance in this script,
                                       // is simply a colour change to denote trial type.
    GameObject redX;
    GameObject motionOrigin;
    //align to start Pos.
    GameObject startFlag;
    // declare public GObjs (assign in inspector)
    public GameObject hmd;
    //public GameObject effector;
    //public GameObject SphereShader;

    void Start()
    {
        // dependencies
        // on scriptholder:
        viveInput = GetComponent<ViveInput>();
        recordData = GetComponent<recordData>();
        walkParams = GetComponent<walkParameters>();
        trialParams = GetComponent<trialParameters>();
        //elsewhere
        targetAppearance = GameObject.Find("Sphere").GetComponent<targetAppearance>();        
        randomWalk = GameObject.Find("Sphere").GetComponent<randomWalk>();       
        walkingGuide = GameObject.Find("motionPath").GetComponent<walkingGuide>();
        showText = GameObject.Find("Instructions (TMP)").GetComponent<showText>();
        changeMat = GameObject.Find("directionCanvas").GetComponent<changeDirectionMaterial>();
        redX = GameObject.Find("RedX");
        motionOrigin = GameObject.Find("motionOrigin");        
         startFlag = GameObject.Find("startPole");
        //flow managers
        TrialCount = 0;       
        trialinProgress = false;
        SetUpSession = true;
        usematerial = 0; // 0=show stop sign, later changed to arrows for walk guide.
        
        changeMat.update(0); // render stop sign
        showText.updateText(1); // show pre trial exp instructions

    }


    private void Update()
    {

        // set up origin at beginning (SetUpSession called only once).
        if (SetUpSession)
        {

          

            CalibrateStartPos(); // align motion origin to player.


            //targetAppearance.setColour(ppantStaircase.preTrialColor); // indicates ready for click to begin trial
            //first trialtype is?


            walkParams.setPathDuration(TrialCount);
        }


        // don't access every frame, but flag is toggled at end of trials / blocks (to show instructions before trial begins). before click to StartTrial
        if (updateText) // 
        {
            determineText(); // method called to determine instructions shown.
            updateText = false; // 
        }

        if (!trialinProgress && setXpos)
        {
            // end of a block, so position new start point:

            // move Red X to the next place on screen:

            float mvmnt = trialParams.blockTypeArray[TrialCount + 1, 2];
            // query if stationary or not.
            isStationary = mvmnt == 0 ? true : false; // 1 and 2 (in mvmnt) corresponds to stationary or moving)
           
            // also round head height?
            CalibrateStartPos();
        }


        // check for startbuttons, but only if not in trial.
        if (!trialinProgress && !setXpos && (viveInput.clickLeft || viveInput.clickRight ) && TrialCount < trialParams.nTrials)
        {
            startTrial(); // starts coroutine, changes listeners, presets staircase.            
        }




        // increment within trial time.
        if (trialinProgress)
        {
            trialTime += Time.deltaTime;
            //print("Trial Time: " + trialTime);
        }


        // check for trial end.
        if (trialinProgress && (trialTime >= walkParams.walkDuration)) // use duration (rather than distance), to account for stationary trials.
        {

            trialPackdown();

            TrialCount++;
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
        // align to room centre:
        Vector3 startO = new Vector3(-.5f, 0, 0);
        Vector3 startX = new Vector3(0, 0, 0);
       

        
        //retain Y position of X (above ground to avoid clipping).
        startX.y = redX.transform.position.y;


        float mvmnt = trialParams.blockTypeArray[TrialCount, 2];
        // query if stationary or not.
        isStationary = mvmnt == 0 ? true : false; // 0  (in mvmnt) corresponds to stationary, else moving.


        if (isStationary)
        {
            motionOrigin.transform.position = startO;
            startX.y = redX.transform.position.y;

        }
        else
        {

            Vector3 flagpos = startFlag.transform.position;

            startO.x = flagpos.x - 1.5f;
            startO.z = flagpos.z - 0.5f;
            startX.x = flagpos.x - 1.5f;
            startX.z = flagpos.z - 0.5f;


        }

        motionOrigin.transform.position = startO;
        redX.transform.position = startX;
        setXpos = false;
        // or align to HMD:

        //GameObject motionOrigin = GameObject.Find("motionOrigin");
        //Vector3 environmentPosition = motionOrigin.transform.position;
        //Vector3 headPosition = hmd.transform.position;

        //// because we start Motion path in the middle, offset this to reposition at HMD.
        //environmentPosition.x = headPosition.x  - walkParams.guideDistance; // - stimParams.guideDistance;
        //environmentPosition.z = headPosition.z;

        //motionOrigin.transform.position = environmentPosition;


        SetUpSession = false;
        walkingGuide.fillStartPos(); // update start pos in WG.


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
        isStationary = mvmnt == 0 ? true : false; // 0 and 1 (in mvmnt) corresponds to stationary or moving)

        // add to trialD for recordData.cs
        trialParams.trialD.trialNumber = TrialCount;
        trialParams.trialD.blockID = trialParams.blockTypeArray[TrialCount, 0];
        trialParams.trialD.trialID = trialParams.blockTypeArray[TrialCount, 1];
        trialParams.trialD.trialType = TrialType;
        //trialParams.trialD.trialType = //TrialType;

        //store bool as int
        float fStat = isStationary ? 1 : 0;
        trialParams.trialD.isStationary = fStat;


        randomWalk.transform.localPosition = walkParams.cubeOrigin;
        randomWalk.origin = walkParams.cubeOrigin;
        walkParams.lowerBoundaries = walkParams.cubeOrigin - walkParams.cubeDimensions;
        walkParams.upperBoundaries = walkParams.cubeOrigin + walkParams.cubeDimensions;

        randomWalk.lowerBoundaries = walkParams.lowerBoundaries;
        randomWalk.upperBoundaries = walkParams.upperBoundaries;
        randomWalk.stepDurationRange = walkParams.stepDurationRange;
        // can't use   = stepDistanceRange; as the string is rounded to 1f precision.
        // so access the dimensions directly:
        randomWalk.stepDistanceRange.x = walkParams.stepDistanceRange.x;
        randomWalk.stepDistanceRange.y = walkParams.stepDistanceRange.y;

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
        Color myGreen = new Color(.02f, .91f, .1f); // bright green

        targetAppearance.setColour(myGreen); // always green or red within a trial
    }

    // based on various listeners, and experiment position, determine which text to show (or hide) from
    // the participant.
    public void determineText()
    {
        // determine if this trial type is different to the last. If so, show instructions, calibrate start Pos.
       
        float mvmnt = trialParams.blockTypeArray[TrialCount , 2];
        float prvmvmnt = trialParams.blockTypeArray[TrialCount-1, 2];
        bool trialhasChanged = mvmnt == prvmvmnt ? false : true;
        
        // query if stationary or not.
        isStationary = mvmnt == 0 ? true : false; 


        if (trialhasChanged) //(trialParams.trialD.trialID == trialParams.ntrialsperBlock - 1)
        {
            // set start position:
            CalibrateStartPos();
            // stationary or not on the next block?


            if (isStationary)
            {
                showText.updateText(3);
                usematerial = 0;
                changeMat.update(0); // Render green arrow.
            }
            else // not could be normal or fast speed.
            {
                //determine speed.

                int btype = trialParams.blockTypeArray[TrialCount, 2];
                showText.updateText(3+btype); // opts: 4,5,6,7
                usematerial = 1; //green arrow.
                changeMat.update(usematerial); // Render green arrow.
            }


            setXpos = true;
        }
        else if (trialParams.trialD.trialID >= 0)
        {
            showText.updateText(87); // just  Trial count between trials.
            setXpos = false;
        }



        updateText = false;
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
        }
        //set speed next trial, colours for next trial: 
        walkParams.setPathDuration(TrialCount + 1); // also changes pretrial target colour
        walkParams.setRWStepDuration(TrialCount + 1);
        targetAppearance.setPreTrialColour(TrialCount + 1);
        targetAppearance.setPreTrialColour(TrialCount + 1);
        updateText = true; // show text between trials


        // set redX to active:
        redX.SetActive(true);
        // return sphere to origin
        randomWalk.transform.localPosition = walkParams.cubeOrigin;

        // align reach height to participant head (in case of slipping).
        Vector3 headPosition = hmd.transform.position;
        headPosition.y = Round(headPosition.y, 1);
        walkParams.reachHeight = hmd.transform.position.y * walkParams.reachBelowPcnt;
        walkParams.updateReachHeight(); // sends to walkGuide.

    }
    public static float Round(float value, int digit)
    {
        float multi = Mathf.Pow(10.0f, (float)digit);
        return Mathf.Round(value * multi) / multi;
    }

}

