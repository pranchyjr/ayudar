using System.Collections;
using System.Collections.Generic;

using UnityEditor;

using UnityEngine;
using UnityEngine.Networking;

public static class session
{

    public static string userName,studentUserName,survayName,studentName, studentDOB,studentGender;
    
    // Start is called before the first frame update

     
}

public class Common
{
    public void setScore(string userName, string levelName, string score)
    {
     
        WWWForm form = new WWWForm();
        form.AddField("userName", userName);
        form.AddField("levelName", levelName);
        form.AddField("score", score);
        
        UnityWebRequest www = UnityWebRequest.Post("https://six-crepe.glitch.me/set_level_score", form);
        www.SendWebRequest();

        if (www.isNetworkError || www.isHttpError)
        {
            Debug.Log(www.error);
        }
        else
        {

          //  EditorUtility.DisplayDialog("Success", "Your Score hasb been saved", "Ok");
            Debug.Log("Form upload complete!");
        }



    }
}
