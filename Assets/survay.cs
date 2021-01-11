using SimpleJSON;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Networking;

public class survay : MonoBehaviour
{

    string studentUsername, type;
    public List<string> keywords = null;
    public List<string> questions = null;

    // Start is called before the first frame update
    IEnumerator Start()
    {
        keywords = new List<string>();
        questions = new List<string>();

        keywords.Add("username");
        questions.Add("Student Name");

        keywords.Add("type");
        questions.Add("Survay Type");



        studentUsername = session.studentUserName;
        type = session.survayName;

        WWWForm form = new WWWForm();
        form.AddField("studentName", studentUsername);
        form.AddField("type", type);

        UnityWebRequest www = UnityWebRequest.Post("https://six-crepe.glitch.me/list_survay", form);
        yield return www.SendWebRequest();

        if (www.isNetworkError || www.isHttpError)
        {
            Debug.Log(www.error);
        }
        else
        {
            Debug.Log("Form upload complete!");

            var N = JSON.Parse(www.downloadHandler.text);
            Debug.Log(www.downloadHandler.text);
            GameObject.Find("jsonText").GetComponent<UnityEngine.UI.Text>().text = replaceModule(www.downloadHandler.text.Replace(",","\n").Replace("{","").Replace("}","").Replace("\"","").Replace(":",":      "));

            //JSONArray arr = (JSONArray)N;




        }




    }

    // Update is called once per frame
    void Update()
    {
        
    }

    string replaceModule(string data)
    {
        string newString=data;
        for (int i=0; i < questions.Count; i++)
        {
            newString = newString.Replace(keywords[i], questions[i]);
        }



        return newString;

    }

}
