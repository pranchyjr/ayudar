
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEditor;
using UnityEngine;
using UnityEngine.Networking;
using UnityEngine.UI;
using UnityEngine.SceneManagement;

public class read : MonoBehaviour
{
    string mispronounce, unfamilier_word, loud_reading, strugle, avoid_reading;
    // Start is called before the first frame update
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }

    public void buttonClick()
    {

        mispronounce = GameObject.Find("GameObject").GetComponent<UnityEngine.UI.ToggleGroup>().ActiveToggles().FirstOrDefault().GetComponentInChildren<Text>().text;
        unfamilier_word = GameObject.Find("GameObject (1)").GetComponent<UnityEngine.UI.ToggleGroup>().ActiveToggles().FirstOrDefault().GetComponentInChildren<Text>().text;
        loud_reading =  GameObject.Find("GameObject (2)").GetComponent<UnityEngine.UI.ToggleGroup>().ActiveToggles().FirstOrDefault().GetComponentInChildren<Text>().text;
        strugle =  GameObject.Find("GameObject (3)").GetComponent<UnityEngine.UI.ToggleGroup>().ActiveToggles().FirstOrDefault().GetComponentInChildren<Text>().text;
        avoid_reading = GameObject.Find("GameObject (4)").GetComponent<UnityEngine.UI.ToggleGroup>().ActiveToggles().FirstOrDefault().GetComponentInChildren<Text>().text;

        WWWForm form = new WWWForm();
        form.AddField("username", session.userName);
        form.AddField("type", "reading");
        form.AddField("mispronounce", mispronounce);
        form.AddField("unfamilier_word",unfamilier_word );
        form.AddField("loud_reading", loud_reading);
        form.AddField("strugle", strugle);
        form.AddField("avoid_reading", avoid_reading);

        UnityWebRequest www = UnityWebRequest.Post("https://six-crepe.glitch.me/set_student_measures", form);
        www.SendWebRequest();

        if (www.isNetworkError || www.isHttpError)
        {
            Debug.Log(www.error);
        }
        else
        {

          //           EditorUtility.DisplayDialog("Success", "Your Recordings has been saved", "Ok");
            SceneManager.LoadScene("spelling");

            Debug.Log("Form upload complete!");
        }





        //Debug.Log("username=" + frustration);

    }
}
