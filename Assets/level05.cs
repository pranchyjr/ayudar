using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class level05 : MonoBehaviour 
{
   Texture2D myTexture;
   InputField iField;
  int imgscore,i;
 public Text result;
 public Button button;
  string myName;
  List<string> images =new List<string>();
void Start()

{    i=0; 
    imgscore = 0;
         images.Add("snake"); 
         images.Add("horse");
         images.Add("CAR");
         images.Add("FOOTBALL");
         images.Add("CAT");

        myTexture = Resources.Load("CAT") as Texture2D;
        GameObject rawImage = GameObject.Find("RawImage");
        rawImage.GetComponent<UnityEngine.UI.RawImage>().texture = myTexture;
           

}
      
       public void cscene(string scenename)
{
    Application.LoadLevel(scenename);
    
}
       public void StudentButtonClick()
    {
      //Debug.Log("inside");
       GameObject InputField = GameObject.Find("iField");
       myName=InputField.GetComponent<UnityEngine.UI.InputField>().text;
        if(myName=="CAT")
         {
           // Debug.Log(myName);
            imgscore=imgscore+20;
           Debug.Log(imgscore);
           iField.text ="";

         }
          i = i + 1;
            if (i < images.Count)
            {


                myTexture = Resources.Load(images[i]) as Texture2D;
                GameObject rawImage = GameObject.Find("RawImage");
                rawImage.GetComponent<UnityEngine.UI.RawImage>().texture = myTexture;
        }
        else
        {  
          
                GameObject rawImage = GameObject.Find("RawImage");
                rawImage.SetActive(false);
                
                GameObject iField = GameObject.Find("iField");
                iField.SetActive(false);
            Common common = new Common();
            GameObject scoreText = GameObject.Find("result");
            scoreText.GetComponent<UnityEngine.UI.Text>().text = "" + imgscore;
            common.setScore(session.userName, "level_05", imgscore.ToString());


        }
        // Debug.Log(myName);
    
    }

}