using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FrameRate : MonoBehaviour {
    public int targetFrameRate = 165;

    private void Awake() {
        Application.targetFrameRate = targetFrameRate;
    }
}