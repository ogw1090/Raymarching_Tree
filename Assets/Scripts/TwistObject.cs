using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TwistObject : MonoBehaviour
{
    public string str_k;
    public string str_color;

    private MeshRenderer m;
    private Vector3 mouse;
    private Color color;
    private Color lerpedColor;
    private Color bloomColor;
    float ini_posx;
    float dist = 0;
    int count = 0;
    const float MAX_RANGE = 30;


    // Start is called before the first frame update
    void Start()
    {
        m = this.GetComponent<MeshRenderer>();
        bloomColor = new Color(191, 32, 40);
    }

    // Update is called once per frame
    void Update()
    {
        mouse.x = MAX_RANGE * (Input.mousePosition.x - Screen.width / 2) / Screen.width;

        if (Input.GetMouseButton(0)) //マウスがクリックされたら
        {
            if (count == 0)
            {
                ini_posx = mouse.x;
            }
            dist = mouse.x - ini_posx;
            m.material.SetFloat(str_k, Mathf.Clamp(dist, -MAX_RANGE, MAX_RANGE));
            count++;
            Debug.Log(mouse.x);
        }

        if (Input.GetMouseButtonUp(0)) //マウスが離されたら
        {
            StartCoroutine(SincCurve(dist));
            count = 0;
            dist = 0;
            color = new Color(191, 191, 191, 0);
            m.material.SetColor(str_color, color);
            StartCoroutine("ScatterdPulmBlossoms");
        }

        if (Input.GetMouseButtonDown(1)) //右クリック
        {
            Debug.Log("aa");
        }


    }

    IEnumerator SincCurve(float d)
    {
        float x = 0;
        float ymax = d;
        while (true)
        {

            float b = ymax * Mathf.Sin(x) / (2 * x) ;
            m.material.SetFloat(str_k, b);

            x += 0.5f;
            yield return new WaitForSeconds(0.01f);

            if (x > 50f)
            {
                yield break;
            }

        }

    }

    IEnumerator ScatterdPulmBlossoms()
    {
        yield return new WaitForSeconds(3.0f);
        float t = 0;
        while(true)
        {
            t += 0.01f;
            m.material.SetColor(str_color, Color.Lerp(color, bloomColor, t));

            if (t > 10.0f)
            {
                yield break;
            }

            Debug.Log(Color.Lerp(color, bloomColor, t));
            yield return new WaitForSeconds(0.01f);
        }

    }


}
