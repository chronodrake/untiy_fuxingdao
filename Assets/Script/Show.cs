using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Show : MonoBehaviour
{
    // Start is called before the first frame update
    [SerializeField]
    public  GameObject Window1;
    public  GameObject Window2;
    public GameObject Window3;

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
        Window1.SetActive(true);
        yield return new WaitForSeconds(5);
        Window2.SetActive(true);
        yield return new WaitForSeconds(5);
        Window3.SetActive(true);
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
