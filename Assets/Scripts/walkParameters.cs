using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class walkParameters : MonoBehaviour
{

    // params for random walk and path motion. Are set to public for easy tweaking in inspector mode.
    // To hide in the inspector (but be serialized), use 
    // [HideInInspector]

    // random walk params
    [Header("Walking/Tracking Parameters")]
    //public float trialDuration;
    public float reachHeight;
    public float walkingPathDistance;
    public float walkingSpeed;
    public float walkDuration;
    private float normDuration;
    private float slowDuration;
    public float guideDistance;
    public float reachBelowPcnt;
    // Hide the following in the inspector, as we don't want tweaking.
    //[HideInInspector]
    public float rampDistance;
    [HideInInspector]
    public float rampDuration;

    [HideInInspector]
    public Vector2 stepDurationRange;
    [HideInInspector]
    public Vector2 stepDistanceRange, normalTgRange, fastTgRange;



    // dimensionality
    [Header("Target Location and Boundaries")]
    public Vector3 planeOrigin;
    public Vector3 cubeOrigin;
    public Vector3 planeDimensions;
    public Vector3 cubeDimensions;
    public Vector3 upperBoundaries;
    public Vector3 lowerBoundaries;


    [HideInInspector]
    public Vector3 passiveTaskOrigin;
    [HideInInspector]
    public float passiveTaskDistance;

    trialParameters trialParams;
    runExperiment runExp;
    targetAppearance targetAppearance;
    walkingGuide walkingGuide;

    public GameObject motionPath;
    // set all variables at Awake, to set variables at initialization.
    // That way, these fields will be available in other scripts Start () calls
    void Start()
    {
        //rw params:
        //trialDuration = 120f;
        reachHeight = 1.3f;

        // walkingSpeed = 0.7f; 
        normDuration = 9f;//  // this needs to be toggled based on trial type.
        slowDuration = 15f;
        walkDuration = normDuration; // to begin with.
        walkingPathDistance = 9.5f;//  Determines end point. 
        //approx steps is dist / 0.5
        reachBelowPcnt = 0.8f; // offset for motion origin below head height. 
        rampDistance = 0f;// 0.7f; // used in walkingGuide, added to total path distance above.
        rampDuration = 1f; // used in walkingGuide
        guideDistance = 0.3f; // this is an offset, used to place the WG in front of the HMD, on calibration
        // dimensionality

        planeOrigin = new Vector3(0, 0, 0);
        cubeOrigin = new Vector3(0, 0, 0);
        planeDimensions = new Vector3(0.22f, 1f, .1f);
        //cubeDimensions = new Vector3(.25f, .25f, .25f);
        cubeDimensions = new Vector3(.15f, .15f, .15f);

        stepDurationRange = new Vector2(0.2f, 0.45f); // how long between changes of direction?
        
        stepDistanceRange = new Vector2(0.03f, 0.045f); // set with David 2020-02-13 (RTKeys)
        normalTgRange = stepDistanceRange;
        fastTgRange = new Vector2(0.07f, 0.08f); // bigger lurches in the target position.

        trialParams = GetComponent<trialParameters>();
        targetAppearance = GameObject.Find("Sphere").GetComponent<targetAppearance>();
        walkingGuide = GameObject.Find("motionPath").GetComponent<walkingGuide>();
        motionPath = GameObject.Find("motionPath");
    }

    // a method for updating the walkPathduration (called at trial start).
    public void setPathDuration(int trialCount)
    {
        // based on block type (btype)
        // set the speeds (see trialParameters for assignment)
        // 1 = slow walk, slow sphere
        // 2 = slow walk, fast sphere
        // 3 = normal walk, slow sphere
        // 4 = normal walk, fast sphere

        int btype = trialParams.blockTypeArray[trialCount, 2];

        if (btype ==1 || btype == 2) //slow walk (1,2)
        {
            walkDuration = slowDuration;
            print("for trial: " + (trialCount +1) + ", setting slow walk speed");
        } else if (btype == 0 ||  btype>2) // normal walk pace (3,4) and for stationary practice(0)
        {
            walkDuration = normDuration;

            print("for trial: " + (trialCount + 1) + ", setting normal walk speed");
        }



    }

    // method to change RW behaviour based on trialtype
    public void setRWStepDuration(int trialCount)
    {
        // based on block type (btype)
        // set the speeds (see trialParameters for assignment)
        // 1 = slow walk, slow sphere
        // 2 = slow walk, fast sphere
        // 3 = normal walk, slow sphere
        // 4 = normal walk, fast sphere

        int btype = trialParams.blockTypeArray[trialCount, 2];
        // set speed based on btype:

        if (btype == 1 || btype == 3) //slow tg (1,3)
        {
            stepDistanceRange = normalTgRange;
            print("for trial: " + trialCount + ", setting normal target speed");
        }
        else if (btype == 2 || btype == 4) // fast tg (2,4)
        {
            stepDistanceRange = fastTgRange;

            print("for trial: " + trialCount + ", setting fast target speed");
        }


    }
    // METHODS:
    public void updateReachHeight()
    {
        Vector3 currentPos = motionPath.transform.localPosition;
        Vector3 updatePosition = new Vector3(currentPos.x, reachHeight, currentPos.z);
        // update motionPath height.

        motionPath.transform.localPosition = updatePosition;
        //transform.localPosition = updatePosition;//

    }
}


