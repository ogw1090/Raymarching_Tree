using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.VFX;

public class TwistObject : MonoBehaviour
{
    public string str_k;
    public string str_color;
    public string str_birdPos;
    public GameObject obj;

    private MeshRenderer m;
    private Vector3 mouse;
    private Color color;
    private Color lerpedColor;
    private Color bloomColor;
    private Vector3 birdPos_def;
    private Vector3 birdPos_esc;
    private Vector3 birdPos_ini;
    private Vector3 birdPos_now;
    private VisualEffect vfx;

    float ini_posx;
    float dist = 0;
    int count = 0;
    const float MAX_RANGE = 30;


    // Start is called before the first frame update
    void Start()
    {
        m = this.GetComponent<MeshRenderer>();
        bloomColor = new Color(191, 32, 40, 255);
        birdPos_def = new Vector3(0.05f, 0.16f, -0.01f);
        birdPos_esc = new Vector3(-0.54f, 0.56f, 0.34f);
        birdPos_ini = new Vector3(0.71f, 0.25f, 0.0f);
        vfx = obj.GetComponent<VisualEffect>();
        StartCoroutine("LandAtBranch");
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
                if(birdPos_now == birdPos_def)
                {
                    StartCoroutine("TakeOffByBird");
                }
            }
            dist = mouse.x - ini_posx;
            m.material.SetFloat(str_k, Mathf.Clamp(dist, -MAX_RANGE, MAX_RANGE));
            count++;
            //Debug.Log(mouse.x);
        }

        if (Input.GetMouseButtonUp(0)) //マウスが離されたら
        {
            //Debug.Log("マウスが離されたら");
            StartCoroutine(SincCurve(dist));
            count = 0;
            dist = 0;
            vfx.SendEvent("OnPlay");
            StartCoroutine("ScatterdPulmBlossoms");
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
        color =  new Color(191, 191, 191, 255);
        m.material.SetColor(str_color, color);

        yield return new WaitForSeconds(3.0f);

        float t = 0;
        while(true)
        {
            t += 0.01f;
            m.material.SetColor(str_color, Color.Lerp(color, bloomColor, t));

            if (t > 2.0f)
            {
                StartCoroutine("ComeBack");
                yield break;
            }

            //Debug.Log(Color.Lerp(color, bloomColor, t));
            yield return new WaitForSeconds(0.01f);
        }

    }

    IEnumerator TakeOffByBird()
    {
        float t = 0.0f;
        while(true)
        {
            t += 0.1f;
            birdPos_now = Vector3.Lerp(birdPos_def, birdPos_esc, t);
            m.material.SetVector(str_birdPos, birdPos_now);
            yield return new WaitForSeconds(0.01f);

            if(t > 1.0f)
            {
                yield break;
            }
        }

    }

    IEnumerator LandAtBranch()
    {
        yield return new WaitForSeconds(2.0f);

        float t = 0.0f;
        while (true)
        {
            t += 0.01f;
            birdPos_now = Vector3.Slerp(birdPos_ini, birdPos_def,Mathf.Sqrt(Mathf.Sqrt(t)));
            m.material.SetVector(str_birdPos, birdPos_now);
            yield return new WaitForSeconds(0.01f);

            if (t > 1.0f)
            {
                yield break;
            }
        }

    }

    IEnumerator ComeBack()
    {
        //Debug.Log("ComeBack");
        yield return new WaitForSeconds(4.0f);

        float t = 0.0f;
        while (true)
        {
            t += 0.01f;
            birdPos_now = Vector3.Slerp(birdPos_esc, birdPos_def, Mathf.Sqrt(Mathf.Sqrt(t)));
            m.material.SetVector(str_birdPos, birdPos_now);
            yield return new WaitForSeconds(0.01f);

            if (t > 1.0f)
            {
                yield break;
            }
        }

    }



}
