using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Addpickup : MonoBehaviour
{
    // Start is called before the first frame update
    void Start()
    {
        PickupManager.Instance.AddPickupCount();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
