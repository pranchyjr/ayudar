using UnityEngine;
using UnityEngine.UI;

public class LoadTexture : MonoBehaviour
{
    Texture2D myTexture;

    // Use this for initialization
    void Start()
    {
        // load texture from resource folder
        Debug.Log("Hello: ");
        myTexture = Resources.Load("20190111_114048", typeof(Texture2D)) as Texture2D;

        GameObject rawImage = GameObject.Find("RawImage");
        rawImage.GetComponent<RawImage>().texture = myTexture;
    }




}

