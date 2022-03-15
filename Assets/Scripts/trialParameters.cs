using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class trialParameters : MonoBehaviour
{
    // predefine the stimulus parameters to be used on each trial,
    // //that are not updated based on staircase.
    
    // TRACKING VERSION 0
    
    // to be filled on Start():
    private float trialDur;
    public float nTrials;
    public int nBlocks;
    public int ntrialsperBlock; // 2 block types (stationary and walking).
    public int nStaircaseBlocks;
    public int nRegularBlocks;

    private float nUniqueConditions;
    private int trialsperCondition; // how many times can we repeat a target type (nTargs presented)

    public int[] trialTypeArray; // namount targs presented each walk
    private int[] trialSpeeds; // for the A19 walk space, set per trial.
    public int[,] blockTypeArray; //nTrials x 3 (block, trialID, type)
    private int[] blockTypelist;
    // import other settings:
    walkParameters walkParameters;
    runExperiment runExperiment;


    //[System.Serializable]
    public struct trialData
    {
        public float trialNumber, blockID, trialID, isStationary, trialType;

    }

    public trialData trialD;

    // create public lists of for updating in runExperiment, read by RecordData 

    public List<string> trialTypeList = new List<string>(); // populated below.

    public List<int> trialsper = new List<int>(); // presented per walk.

    public Color preTrialColor; // green, to show ready/idle state
    //public Color probeColor; // grey
    //public Color targetColor; // white, decreasing in contrast to match probe over staircase.
    void Start()
    {

        walkParameters = GameObject.Find("scriptHolder").GetComponent<walkParameters>();
        runExperiment = GameObject.Find("scriptHolder").GetComponent<runExperiment>();

        // gather presets
        trialDur = walkParameters.walkDuration; // in second, determines how many targets we can fit in.

        // set colours
        preTrialColor = new Color(0f, 1f, 0f, 1); //drk green
        //probeColor = new Color(0.4f, 0.4f, 0.4f, targetAlpha); // dark grey
        //targetColor = new Color(.55f, .55f, .55f, targetAlpha); // light grey (start easy, become difficult).

        ////////////////////////////////////
        ///////////////////////////////////////
        ///////////////////////////////////////
        ////////////////////////////////////
        ntrialsperBlock = 20; //
        //
        nStaircaseBlocks = 1; // In this block, first blocks (staircase) contains trials of each param
                              // note there are 5 conds (stationary, slow-slow, slow-fast, normal-slow, normal-fast)
                              // do 4 trials of each per block (20/5 =4)
        nRegularBlocks = 8; //(2 x ntrialsperBlock of each walk combination)
        ////////////////////////////////////
        ///////////////////////////////////////
        ///////////////////////////////////////
        ///////////////////////////////////////
        nBlocks = nStaircaseBlocks + nRegularBlocks;
        nTrials = (nBlocks) * ntrialsperBlock;
        blockTypelist = new int[(int)nBlocks]; // populated below.

        // next, we will determine how many targets to present in our given walk duration (max 3 for home testing).
        // prefill the trialTypeArrayy as we go:

        //trialSpeeds = new int[2]; // nspeeds of sphere movement.
        //trialSpeeds[0] = 1; // first speed (normal pace)
        //trialSpeeds[1] = 2; // second speed (half pace)

        

        // also create wrapper to determine which blocks can be stationary or walking.
        // first staircase blocks are always stationary.
        // hardcoded for current trial numbers.
        // TODO: flexibly update for nTrials required.

        int icounter = 0;
        blockTypelist = new int[nRegularBlocks]; // omit first  (calib) blocks.

        // block type determines walking speed, and sphere speed
        // 0 = staircase, special case (see below)
        // 1 = slow walk, slow sphere
        // 2 = slow walk, fast sphere
        // 3 = normal walk, slow sphere
        // 4 = normal walk, fast sphere
        // FILL BLOCKS
        int[] BLOCKtypeArray = new int[4];
        BLOCKtypeArray[0] = 1;
        BLOCKtypeArray[1] = 2;
        BLOCKtypeArray[2] = 3;
        BLOCKtypeArray[3] = 4;

        int typec = 0;
        // fill amount of blocks we have with the above types
        for (int iblock = 0; iblock<nRegularBlocks; iblock++)
        {
            blockTypelist[iblock] = BLOCKtypeArray[typec];
            typec++;
            if (typec == 4)
            {
                typec = 0;
            }
           
        }


        // shuffle the order of stationary (0s) and walking (1s) blocks
        shuffleArray(blockTypelist);

        blockTypeArray = new int[(int)nTrials, 3]; // 3 columns.
                                                   // ensure first staircased trials are stationary.
        int typeCount = 0; // we will do half the trials of each type in our staircase:
        

        int nTrialsperTypestaircase = ntrialsperBlock / 5; // even number output!
        int[] practicetypeArray = new int[10];
        practicetypeArray[0] = 0; // stationary to begin with.                         
        practicetypeArray[1] = 3; // normal walk- slow sphere
        practicetypeArray[2] = 4; // normal walk fast sphere
        practicetypeArray[3] = 1; // slow walk -  slow sphere
        practicetypeArray[4] = 2; // slow - fast
        practicetypeArray[5] = 4; // norm fast
        practicetypeArray[6] = 1; // slow slow
        practicetypeArray[7] = 3; // norm slow
        practicetypeArray[8] = 2; // slow fast
        practicetypeArray[9] = 4; // norm fast 


        // staircaseblocks:
        int bcounter = 0; // blockcounter
        int fillme = 1;
        for (int iblock = 0; iblock < nStaircaseBlocks; iblock++)
        {
            if (typeCount == nTrialsperTypestaircase+1) // increment blockcounter
            { bcounter = bcounter + 1;}
            
            for (int itrial = 0; itrial < ntrialsperBlock; itrial++)
            {
                blockTypeArray[icounter, 0] = bcounter;
                blockTypeArray[icounter, 1] = itrial; // trial within block
                blockTypeArray[icounter, 2] = practicetypeArray[typeCount]; // prefill this array, swapping half way through the block.
                // when running the staircase, we will update the sphere speed half way through the block
                icounter++;

                if (fillme == nTrialsperTypestaircase)
                {
                    typeCount++;
                    fillme = 1; // reset

                } else { fillme++; }
                
            }
           

        }

        //now fill remaining blocks 
        //
        for (int iblock = nStaircaseBlocks; iblock < nBlocks; iblock++)
        {
            for (int itrial = 0; itrial < ntrialsperBlock; itrial++)
            {
                blockTypeArray[icounter, 0] = iblock;
                blockTypeArray[icounter, 1] = itrial;
                blockTypeArray[icounter, 2] = blockTypelist[iblock - nStaircaseBlocks]; //mvmnt (randomized).

                icounter++;
            }

        }

    }

    /// 
    /// 
    /// METHODS:
    /// 
    /// 
    /// 
    // shuffle array once populated.
    void shuffleArray(int[] a)
    {
        int n = a.Length;


        for (int id = 0; id < n; id++)
        {
            swap(a, id, id + Random.Range(0, n - id));
        }
    }
    void swap(int[] inputArray, int a, int b)
    {
        int temp = inputArray[a];
        inputArray[a] = inputArray[b];
        inputArray[b] = temp;

    }
}



