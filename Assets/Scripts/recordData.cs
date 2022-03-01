using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEngine;

public class recordData : MonoBehaviour
{
    /// <summary>
    ///  Detailed position recording for head, target, and effector (hand). 
    ///  Recording the x y z position at every frame, and time (deltaTime).
    /// </summary>

    string outputFolder, outputFile_pos, outputFile_summary;
    float trialTime = 0f;
    string[] timePointAxis = new string[9];
    string[] timePointObject = new string[9];
    float[] timePointPosition = new float[9];

    public GameObject
        Sphere, effector, hmd;


    List<string> outputData_pos = new List<string>();
    List<string> outputData_summary = new List<string>();

    runExperiment runExperiment;
    ViveInput viveInput;
    trialParameters trialParameters;
    public enum phase // these fields can be set by other scripts (runExperiment) to control record state.
    {
        idle,
        collectResponse,
        collectTrialSummary,
        stop
    };

    //set to idle
    public static phase recordPhase = phase.idle;

    private int clickState; // click down or no
    private int targState; // targ shown or now.

    void Start()
    {
        runExperiment = GetComponent<runExperiment>();
        viveInput = GetComponent<ViveInput>();
        trialParameters = GetComponent<trialParameters>();


        // create text file for Position tracking data.
        createPositionTextfile(); // below for details.

        //create text file for trial summary data:
        //createSummaryTextfile();
       
    }

    void Update()
    {
        if (recordPhase == phase.idle)
        {
            if (trialTime > 0)
            {
                trialTime = 0;
            }
        }

        if (recordPhase == phase.collectResponse) 
        {
            // record target and effector ('cursor') position every frame
            // for efficiency, only call 'transform' once per frame
            Vector3 currentTarget = Sphere.transform.position;
            Vector3 currentVeridicalEffector = effector.transform.position;
            Vector3 currentHead = hmd.transform.position;

           // convert from bool
           
            //clickState =  condition ? consequent : alternative
            clickState = viveInput.clickRight ? 1 : 0;

            timePointPosition[0] = currentTarget.x;
            timePointPosition[1] = currentTarget.y;
            timePointPosition[2] = currentTarget.z;
            timePointPosition[3] = currentVeridicalEffector.x;
            timePointPosition[4] = currentVeridicalEffector.y;
            timePointPosition[5] = currentVeridicalEffector.z;
            timePointPosition[6] = currentHead.x;
            timePointPosition[7] = currentHead.y;
            timePointPosition[8] = currentHead.z;

            for (int j = 0; j < timePointPosition.Length; j++)
            {
                string data =
                    System.DateTime.Now.ToString("yyyy-MM-dd") + "," +
                    runExperiment.participant + "," +
                    runExperiment.TrialCount + "," +
                    trialTime + "," +
                    timePointObject[j] + "," +
                    timePointAxis[j] + "," +
                    timePointPosition[j] + "," +
                    clickState;
                  

                outputData_pos.Add(data);
            }

            trialTime += Time.deltaTime;
        }
      

        if (recordPhase == phase.stop)
        {
            trialTime = 0;
            recordPhase = phase.idle; ////////////////////////////////////////////////////////////////////////////////////////// make sure timer is reset
        }
    }
    ///
    ///  Called methods below:
    /// 
   
    private void OnApplicationQuit()
    {
        saveRecordedDataList(outputFile_pos, outputData_pos);
        //saveRecordedDataList(outputFile_summary, outputData_summary);
    }

    static void saveRecordedDataList(string filePath, List<string> dataList)
    {
        // Robert Tobin Keys:
        // I wrote this with System.IO ----- this is super efficient

        using (StreamWriter writeText = File.AppendText(filePath))
        {
            foreach (var item in dataList)
                writeText.WriteLine(item);
        }
    }

    private void createPositionTextfile()
    {
        //outputFolder = "C:/Users/vrlab/Documents/Matt/Projects/Output/walking_Ver1_Detect/";
        outputFolder = "C:/Users/User/Documents/matt/GitHub/active-perception-tracking_ver0/Analysis Code/Tracking ver 0/Raw_data/";
        outputFile_pos = outputFolder + runExperiment.participant + "_" + System.DateTime.Now.ToString("yyyy-MM-dd-hh-mm") + "_framebyframe.csv";


        string columnNames = "date," +
            // add experiment: walkingTracking2D
            "participant," +
            "trial," +
            "t," +
            "trackedObject," +
            "axis," +
            "position," +
            "clickstate," +           
            "\r\n";

        File.WriteAllText(outputFile_pos, columnNames);



        timePointAxis[0] = "x";
        timePointAxis[1] = "y";
        timePointAxis[2] = "z";
        timePointAxis[3] = "x";
        timePointAxis[4] = "y";
        timePointAxis[5] = "z";
        timePointAxis[6] = "x";
        timePointAxis[7] = "y";
        timePointAxis[8] = "z";

        timePointObject[0] = "target";
        timePointObject[1] = "target";
        timePointObject[2] = "target";
        timePointObject[3] = "effector";
        timePointObject[4] = "effector";
        timePointObject[5] = "effector";
        timePointObject[6] = "head";
        timePointObject[7] = "head";
        timePointObject[8] = "head";
    }


    private void createSummaryTextfile()
    {
        //outputFolder = "C:/Users/vrlab/Documents/Matt/Projects/Output/walking_Ver1_Detect/";
        outputFolder = "C:/Users/User/Documents/matt/GitHub/active-perception-Detection_v1-1wQuest/Analysis Code/Detecting ver 0/Raw_data/";

        outputFile_summary = outputFolder + runExperiment.participant + "_" + System.DateTime.Now.ToString("yyyy-MM-dd-hh-mm") + "_trialsummary.csv";

        string columnNames = "date," +
            "participant," +
            "trial," +
            "block," +
            "trialID," + // walk/speed combo
            "isPrac," +
            "isStationary," +           
            "," +
            "\r\n";

        File.WriteAllText(outputFile_summary, columnNames);


    }

    // use a method to perform on relevant frame at trial end.
    public void collectTrialSummary()
    {

        // at the end of each trial (walk trajectory), export the details as a summary.
        // col names specified below (createSummaryTextfile)

        // convert data of interest:



        // convert bools to ints.
        int testPrac = runExperiment.isPractice ? 1 : 0;

        // fill data:
        //    "date,"+
        //    "participant," +
        //    "trial," +
        //    "block," +
        //    "trialID," +
        //    "isPrac," +
        //    "isStationary," +
        //    "," +
        //    "\r\n";

        string data =
                  System.DateTime.Now.ToString("yyyy-MM-dd") + "," +
                  runExperiment.participant + "," +
                  runExperiment.TrialCount + "," +
                  trialParameters.trialD.blockID + "," +
                  trialParameters.trialD.trialID + "," +
                  testPrac + "," +
                  trialParameters.trialD.isStationary + "," +
                  ",";
                  

        outputData_summary.Add(data);

    }
}



