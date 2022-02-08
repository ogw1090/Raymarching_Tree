using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TwistObject : MonoBehaviour
{
    public string str;
    private MeshRenderer m;
    private Vector3 mouse;
    float ini_posx;
    float dist = 0;
    int count = 0;
    const float MAX_RANGE = 30;


    // Start is called before the first frame update
    void Start()
    {
        m = this.GetComponent<MeshRenderer>();
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
            m.material.SetFloat(str, Mathf.Clamp(dist, -MAX_RANGE, MAX_RANGE));
            count++;
            Debug.Log(mouse.x);
        }

        if (Input.GetMouseButtonUp(0)) //マウスが離されたら
        {
            StartCoroutine(SincCurve(dist));
            count = 0;
            dist = 0;
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
            m.material.SetFloat(str, b);

            x += 0.5f;
            yield return new WaitForSeconds(0.01f);

            if (x > 50f)
            {
                yield break;
            }

        }

    }
}
