using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraRotater : MonoBehaviour {
    public float moveSpeed;
    public float rotateSpeed;
    public Transform cam;

    private void Update() {
        if (Input.GetKey(KeyCode.A)) {
            cam.Translate(Vector3.forward * moveSpeed * 0.2f, Space.World);
        }

        if (Input.GetKey(KeyCode.D)) {
            cam.Translate(Vector3.back * moveSpeed * 0.2f, Space.World);
        }

        if (Input.GetMouseButton(0)) {
            cam.Translate(Vector3.back * Input.GetAxis("Mouse X") * moveSpeed, Space.World);
        }

        if (Input.GetMouseButton(1)) {
            cam.RotateAround(transform.position, Vector3.up, Input.GetAxis("Mouse X") * rotateSpeed);
        }
    }
}