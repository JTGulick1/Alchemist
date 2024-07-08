using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class GrowandShrink : MonoBehaviour
{
    public TMPro.TMP_Text uiText; // Reference to the Text component
    public float minScale = 0.8f; // Minimum scale value
    public float maxScale = 1.2f; // Maximum scale value
    public float speed = 2f; // Speed of scaling

    private bool isGrowing = true;
    private RectTransform rectTransform;

    void Start()
    {
        if (uiText == null)
        {
            uiText = GetComponent<TMPro.TMP_Text>();
        }
        rectTransform = uiText.GetComponent<RectTransform>();
    }

    void Update()
    {
        if (isGrowing)
        {
            rectTransform.localScale += Vector3.one * speed * Time.deltaTime;
            if (rectTransform.localScale.x >= maxScale)
            {
                isGrowing = false;
            }
        }
        else
        {
            rectTransform.localScale -= Vector3.one * speed * Time.deltaTime;
            if (rectTransform.localScale.x <= minScale)
            {
                isGrowing = true;
            }
        }
    }
}
