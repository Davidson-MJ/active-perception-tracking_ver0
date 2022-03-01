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

    // Hide the following in the inspector, as we don't want tweaking.
    //[HideInInspector]
    public float rampDistance;
    [HideInInspector]
    public float rampDuration;

    [HideInInspector]
    public Vector2 stepDurationRange;
    [HideInInspector]
    public Vector2 stepDistanceRange;



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
    
    
    // set all variables at Awake, to set variables at initialization.
    // That way, these fields will be available in other scripts Start () calls
    void Start()
    {
        //rw params:
        //trialDuration = 120f;
        //reachHeight = 1.3f;
       
       // walkingSpeed = 0.7f; 
        normDuration = 9f;//  // this needs to be toggled based on trial type.
        slowDuration = 18f;
        walkingPathDistance = 9.5f;//  Determines end point. 
        //approx steps is dist / 0.5

        rampDistance = 0f;// 0.7f; // used in walkingGuide, added to total path distance above.
        rampDuration = 1f; // used in walkingGuide
        guideDistance = 0.3f; // this is an offset, used to place the WG in front of the HMD, on calibration
        // dimensionality

        planeOrigin = new Vector3(0, 0, 0);
        cubeOrigin = new Vector3(0, 0, 0);
        planeDimensions = new Vector3(0.22f, 1f, .1f);
        cubeDimensions = new Vector3(.25f, .25f, .25f);
        stepDurationRange = new Vector2(0.2f, 0.4f);
        stepDistanceRange = new Vector2(0.03f, 0.045f); // set with David 2020-02-13 (RTKeys)
        


    }

    // a method for updating the walkPathduration
    public void setPathDuration(int btype)
    {
        // based on block type (btype)
        // set the speeds (see trialParameters for assignment)
        
        if (btype<=2) //slow walk (1,2)
        {
            walkDuration = slowDuration
        } else if (btype>2) // normal walk pace (3,4)
        {
            walkDuration = normDuration;
        }
    }
}


