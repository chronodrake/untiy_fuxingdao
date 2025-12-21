using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Show : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField]
    public  GameObject show1;
    public  GameObject show2;
    public GameObject show3;
    public GameObject show4;
    public GameObject show5;
    public GameObject show6;
    public float waitSeonds = 3;
    void Start()
    {
        StartShow();
    }
    public void StartShow()
    {
        StartCoroutine(ShowWindow());
    }
    IEnumerator ShowWindow()
    {
        yield return new WaitForSeconds(waitSeonds);
        show1.SetActive(true);
        yield return new WaitForSeconds(waitSeonds);
        show2.SetActive(true);
        yield return new WaitForSeconds(waitSeonds);
        show3.SetActive(true);
        yield return new WaitForSeconds(waitSeonds);
        show4.SetActive(true);
        yield return new WaitForSeconds(waitSeonds);
        show5.SetActive(true);
        yield return new WaitForSeconds(waitSeonds);
        show6.SetActive(true);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
